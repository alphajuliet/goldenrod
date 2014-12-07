#!/usr/bin/env ruby

$:.unshift("src")
require 'my_prefixes'
require 'pipeline'
require 'projects'

stardog_home = "/usr/local/lib/stardog-2.2.2"
stardog = "#{stardog_home}/bin/stardog"
ns_sfdc = "http://alphajuliet.com/ns/rsa/sfdc#"
ns_proj = "http://alphajuliet.com/ns/rsa/proj#"
db = "goldenrod"

desc "Generate all pipeline RDF files"
task :sfdc do
  FileList.new("data/*-sfdc.csv").each do |csv|
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

desc "Test task"
task :proj do
  FileList.new("data/*-projects.csv").each do |csv|
    puts "# Updating #{csv}"
    ttl = csv.sub('.csv', '.ttl')
    p = Projects.new
    p.load_csv(csv.to_s)
    p.convert_to_rdf
    p.to_turtle
    p.write_as_turtle(ttl)
  end
end


desc "Remove all TTL files"
task :clean do
  FileList['data/*.ttl'].each do |f|
    File.delete(f)
  end
end

desc "Load SFDC graphs into the triple store"
task :sfdc_load do
  FileList["data/*-sfdc.ttl"].each do |f|
    d = f.match(/\d{4}-\d{2}-\d{2}/)
    graph = ns_sfdc + d.to_s
    cmd = "#{stardog} data add -g \"#{graph}\" #{db} \"#{f}\""
    puts cmd
    system(cmd)
  end
end

desc "Load projects graphs into the triple store"
task :proj_load do
  FileList["data/*-proj.ttl"].each do |f|
    d = f.match(/\d{4}-\d{2}-\d{2}/)
    graph = ns_proj + d.to_s
    cmd = "#{stardog} data add -g \"#{graph}\" #{db} \"#{f}\""
    puts cmd
    system(cmd)
  end
end

desc "Remove all triples"
task :remove_all do
  cmd = "#{stardog} data remove --all #{db}"
  puts cmd
  system(cmd)
end

desc "Count triples in the store"
task :count do
  cmd = "#{stardog} data size #{db}"
  puts cmd
  system(cmd)
end

# The End
