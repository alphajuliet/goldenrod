#!/usr/bin/env ruby

$:.unshift("src")
require 'pipeline'

desc "Generate all pipeline RDF files"
task :sfdc do
  FileList['data/* sfdc.csv'].each do |csv|
    ttl = csv.sub('csv', 'ttl')
    unless uptodate?(ttl, csv)
      puts "# Updating #{csv}"
      p = Pipeline.new
      p.load_csv(csv)
      p.convert_to_rdf
      p.to_turtle
      p.write_as_turtle(ttl)
    end
  end
end

desc "Remove all SFDC TTL files"
task :clean do
  FileList['data/* sfdc.ttl'].each do |f|
    File.delete(f)
  end
end


# The End
