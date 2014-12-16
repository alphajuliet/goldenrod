#!/usr/bin/env ruby

$:.unshift("src")
require 'my_prefixes'
require 'pipeline'
require 'projects'
require 'subcons'

STARDOG_HOME = "/usr/local/lib/stardog-2.2.2"
STARDOG = "#{STARDOG_HOME}/bin/stardog"
NS_SFDC = "http://alphajuliet.com/ns/rsa/sfdc#"
NS_PROJ = "http://alphajuliet.com/ns/rsa/proj#"
NS_SUBCON = "http://alphajuliet.com/ns/rsa/subcon#" 
DB = "goldenrod"

# Generic conversion routine
def to_rdf(pattern, classname)
  FileList.new(pattern).each do |csv|
    ttl = csv.sub('csv', 'ttl')
    unless File.exists?(ttl)
      puts "# Updating #{csv}"
      p = classname.new
      p.load_csv(csv)
      p.convert_to_rdf
      p.to_turtle
      p.write_as_turtle(ttl)
    end
  end
end

desc "Convert SFDC pipeline files to RDF"
task :sfdc_rdf do
  to_rdf("data/*-sfdc.csv", Pipeline)
end

desc "Convert projects to RDF"
task :proj_rdf do
  to_rdf("data/*-projects.csv", Projects)
end

desc "Convert subcontractor status to RDF"
task :subcons_rdf do
  to_rdf("data/*-subcontractors.csv", Subcons)
end

desc "Remove all TTL files"
task :clean_all do
  FileList['data/*.ttl'].each do |f|
    File.delete(f)
  end
end

# Generic RDF load into Stardog
def import_rdf(ns, fname)
  d = fname.match(/\d{4}-\d{2}-\d{2}/)
  graph = ns + d.to_s
  cmd = "#{STARDOG} data add -g \"#{graph}\" #{DB} \"#{fname}\""
  puts cmd
  puts system(cmd)
end

def import_all(ns, pattern)
  FileList[pattern].each do |f|
    d = f.match(/\d{4}-\d{2}-\d{2}/)
    graph = ns + d.to_s
    cmd = "#{STARDOG} data add -g \"#{graph}\" #{DB} \"#{f}\""
    puts cmd
    puts system(cmd)
  end
end

desc "Load an individual SFDC file"
task :sfdc_load, :file do |t, args|
  import_rdf(NS_SFDC, args[:file])
end

desc "Load a subcontractors file"
task :subcons_load, :file do |t, args|
  import_rdf(NS_SUBCON, args[:file])
end

desc "Load SFDC graphs into the triple store"
task :sfdc_load_all do
  import_all(NS_SFDC, "data/*-sfdc.ttl")
end

desc "Load an individual projects file"
task :proj_load, :file do |t, args|
  import_rdf(NS_PROJ, args[:file])
end

desc "Load projects graphs into the triple store"
task :proj_load_all do
  import_all(NS_PROJ, "data/*-projects.ttl")
end

desc "Remove all triples"
task :wipe_database do
  cmd = "#{STARDOG} data remove --all #{DB}"
  puts cmd
  puts system(cmd)
end

desc "Count triples in the store"
task :count do
  cmd = "#{STARDOG} data size #{DB}"
  puts cmd
  system(cmd)
end

desc "Fix boolean import bug in Stardog"
task :fix_booleans do
  FileList["data/*.ttl"].each do |ttl|
    cmd = "sed -re 's/false|true/\"&\"^^xsd:boolean/' #{ttl} > tmp$$; mv tmp$$ #{ttl}"
    puts cmd
    puts system(cmd)
  end
end

# The End
