require 'spec_helper'

module AssayerMiner
  describe "finding the index item" do
    it "gets index item from QPID"
    it "raises an error when there is no relevant item"
  end

  describe "getting the relevant medical record items" do
    it "makes the right search for QPID"
    it "skips the index item"
  end

  describe "generating XML" do
    it "includes the header info"
    it "includes the index item info"
    it "includes the whole set of putative items"
  end
end
