# coding:utf-8
require 'rubygems'
require 'sinatra'
require 'zipruby'
require 'nkf'
require 'RMagick'

get '/' do
  haml :index
end

post '/' do
  name = params[:name]
  @message = ""
  if name.empty?
    return haml :index
  end
  display_name = params[:display_name]
  quotes = params[:quotes]
  successes = params[:successes]
  failures = params[:failures]
  others = params[:others]

  xml_text = generate_xml(name, display_name, quotes, successes, failures, others)
  zip_buffer = ''
  Zip::Archive.open_buffer(zip_buffer, Zip::CREATE, Zip::NO_COMPRESSION) do |archive|
    archive.add_buffer("persona.xml", NKF.nkf('-U -s -Lw', xml_text))
  end

  content_type 'application/zip'
  attachment "#{name}.zip"
  zip_buffer
end

def generate_xml(name, display_name, quotes, successes, failures, others)
  xml = "<persona id='#{name}' displayName='#{display_name}'>\n"
  quotes.split.each do |str|
    xml +=  "  <quote>#{str}</quote>\n"
  end
  successes.split.each do |str|
    xml +=  "  <quote type='success'>#{str}</quote>\n"
  end
  failures.split.each do |str|
    xml +=  "  <quote type='failure'>#{str}</quote>\n"
  end
  others.split.each do |str|
    xml +=  "  <quote type='other'>#{str}</quote>\n"
  end
  xml += "</persona>\n"
  xml
end
