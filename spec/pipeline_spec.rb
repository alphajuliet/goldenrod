#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "src")

require 'pipeline'

RSpec.describe Pipeline do

  p = Pipeline.new
  p.load_csv("data/test.csv")

  it "makes triples" do
    tr = p.convert_to_rdf.triples
    expect(tr).to be_a(Array)
    expect(tr.length).to eq(16)
  end

  it "generates RDF" do
    rdf = p.convert_to_rdf.graph
    expect(rdf).to be_truthy
    expect(rdf.count).to eq(16)
  end

end
      
# The End
