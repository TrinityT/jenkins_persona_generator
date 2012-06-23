# coding:utf-8
require 'rubygems'
require 'sinatra'
require 'zipruby'
require 'nkf'

get '/' do
  haml :index
end

post '/upload' do
  name = params[:name]
  display_name = params[:display_name]
  quotes = params[:quotes]
  successes = params[:successes]
  failures = params[:failures]
  others = params[:others]

  unless params[:image_icon] || params[:image_success] ||
      params[:image_failure] || params[:image_other]
    return haml :index
  end

  file_buffers = generate_file_buffers(params)
  xml_text = generate_xml(name, display_name, quotes, successes, failures, others)

  zip_buffer = ''
  Zip::Archive.open_buffer(zip_buffer, Zip::CREATE, Zip::NO_COMPRESSION) do |archive|
    archive.add_buffer("persona.xml", NKF.nkf('-U -s -Lw', xml_text))
    file_buffers.each_pair do |filename, buf|
      archive.add_buffer(filename, buf)
    end
  end

  content_type 'application/zip'
  attachment "#{name}.zip"
  zip_buffer
end

def generate_file_buffers(params)
  file_buffers = Hash.new
  file = params[:image_icon][:tempfile]
  file_buffers.store("icon.jpg", file.read)
  file = params[:image_success][:tempfile]
  file_buffers.store "success.jpg", file.read
  file = params[:image_failure][:tempfile]
  file_buffers.store "failure.jpg", file.read
  file = params[:image_other][:tempfile]
  file_buffers.store "other.jpg", file.read
  file_buffers
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
