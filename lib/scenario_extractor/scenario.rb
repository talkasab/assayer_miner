module ScenarioExtractor
  class IndexItemNotFound < RuntimeError; end
  class InvalidMedicalRecordNumber < RuntimeError; end
  class InvalidAccessionNumber < RuntimeError; end

  class Scenario
    attr_reader :mrn, :accession_no
    attr_accessor :years_before, :years_after, :record_types

    DEFAULT_YEARS_BEFORE = 2
    DEFAULT_YEARS_AFTER = 2
    DEFAULT_RECORD_TYPES = ["RAD", "OPN", "NDO", "MIC", "PAT"]

    def initialize(mrn, accession_no)
      raise InvalidMedicalRecordNumber, "Must have a MRN" if mrn.blank?
      raise InvalidMedicalRecordNumber, "Only digits allowed in MRN, got #{mrn}" if mrn =~ /\D/
      raise InvalidAccessionNumber, "Must have an accession number" if accession_no.blank?
      raise InvalidAccessionNumber, "Only digits allowed in acc #, got #{accession_no}" if accession_no =~ /\D/
      @mrn = mrn
      @accession_no = accession_no
    end

    def ris_data
      return @ris_data if @ris_data
      sql = "SELECT * FROM [Radmine] WHERE [ACC]=#{accession_no} AND [MRN]='#{mrn}'"
      result = ScenarioExtractor.ris_db_client.execute(sql)
      data = result.each(:as => :hash, :symbolize_keys => true).first
      unless data.present?
        raise IndexItemNotFound, "No radiology exam found for MRN #{mrn} accession #{accession_no} in RIS" 
      end
      @ris_data = data
    end

    def index_item
      return @index_item if @index_item
      search_items = ScenarioExtractor.qpid.search(mrn, Qpid.type("RAD"), accession_no)
      if search_items.blank?
        raise IndexItemNotFound, "No radiology exam found for MRN #{mrn} accession #{accession_no} in QPID" 
      end
      item = search_items.first
      add_report_methods_to_item(item)
      add_ris_methods_to_item(item)
      @index_item = item
    end

    def medical_record_items
      return @items if @items
      update_qpid_if_needed
      items = ScenarioExtractor.qpid.search(mrn, *search_terms)
      items.reject! { |i| i.mid == index_item.mid || (i.type == "OPN" && i.mid =~ /PERI$/) }
      items.each { |i| add_report_methods_to_item(i) }
      @items = items
    end

    def start_date
      exam_date.years_ago(years_before || DEFAULT_YEARS_BEFORE)
    end

    def end_date
      exam_date.years_since(years_after || DEFAULT_YEARS_AFTER)
    end

    def search_terms
      terms = [Qpid.fromdate(start_date), Qpid.todate(end_date)]
      types = record_types.present? ? record_types : DEFAULT_RECORD_TYPES
      terms << '(' + types.map { |t| Qpid.type(t) }.join(" OR ") + ')'
      terms
    end

    def update_qpid_if_needed
      updated = ScenarioExtractor.qpid.updatestatus(mrn)
      if ! updated || updated < end_date
        ScenarioExtractor.qpid.reload(mrn)
      end
    end

    def add_report_methods_to_item(item)
      scenario = self
      metaclass = class << item; self; end
      metaclass.send :define_method, :report do
        @report ||= ScenarioExtractor.qpid.report(scenario.mrn, item)
      end
      metaclass.send :define_method, :anonymized_report do
        @anonymized_report ||= ScenarioExtractor::Anonymizer.anonymize(scenario.name, report)
      end
      metaclass.send :define_method, :days_from_index do
        @days_from_index ||= (date - scenario.exam_date).to_i
      end
    end

    def add_ris_methods_to_item(item)
      scenario = self
      metaclass = class << item; self; end
      metaclass.send :define_method, :comment do
        scenario.comment
      end
      metaclass.send :define_method, :history do
        scenario.history
      end
    end

    def name; ris_data[:NAME]; end

    def sex; ris_data[:SEX]; end

    def date_of_birth; ris_data[:DOB].to_date; end

    def exam_date; ris_data[:COMP_DATE].to_date; end

    def age
      return @age if @age
      age = exam_date.year - date_of_birth.year
      if exam_date.month < date_of_birth.month || 
        (exam_date.month == date_of_birth.month && exam_date.day < date_of_birth.day)
        age -= 1
      end
      @age = age
    end

    def history
      return @history if @history
      @history = [:HIST1, :HIST2, :HIST3].map {|h| ris_data[h]}.join(' ').gsub(/RoeID\d+/, '').strip
    end

    def comment
      return @comment if @comment
      @history = [:MISC1, :MISC2].map {|h| ris_data[h]}.join(' ').strip
    end

    def description
      ris_data[:LONG_DESC] || ris_data[:SHORT_DESC] || ris_data[:EXAM_DESCR] || ris_data[:EXAM_DESCR_LONG]
    end
  end
end
