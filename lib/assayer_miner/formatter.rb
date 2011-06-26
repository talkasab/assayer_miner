require 'builder'
require 'uuidtools'

module AssayerMiner
  module Formatter
    class << self
      def make_scenario_xml(scenario, opts = {})
        defaults = { :uuid => UUIDTools::UUID.random_create }
        opts.reverse_merge!(defaults)
        buffer = ""
        xml = Builder::XmlMarkup.new(:target => buffer, :indent => 2)
        xml.instruct!
        xml.clinical_scenario(opts) do
          xml.patient(:age => scenario.age, :sex => scenario.sex)
          make_index_item_xml(xml, scenario.index_item)
          scenario.medical_record_items.each {|item| make_item_xml(xml, item) }
        end
        buffer
      end

      def make_index_item_xml(xml, index_item)
        xml.index_exam do |xml|
          xml.exam_description index_item.desc
          xml.clinical_history index_item.history
          xml.exam_comment index_item.comment if index_item.comment.present?
          xml.report {|xml| xml.cdata! index_item.anonymized_report }
        end
      end

      def make_item_xml(xml, item)
        attrs = {:id => item.mid, :days_from_index => item.days_from_index, :type => item.type }
        xml.medical_record_item(attrs) do
          xml.description item.desc
          xml.report { xml.cdata! item.anonymized_report }
        end
      end
    end
  end
end
