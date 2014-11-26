#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")
require 'pipeline'

RSpec.describe Pipeline do

  it "makes triples" do
    p = Pipeline.new
    p.load_csv("data/2014-11-24 sfdc.csv")
    rdf = p.to_rdf
    expect(rdf.length).to eq(5850)
    puts rdf[0..10]
  end

end
      
# The End
