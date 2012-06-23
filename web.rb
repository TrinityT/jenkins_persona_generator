# coding:utf-8
require 'sinatra'

get '/' do
  haml :index
end

post '/' do
  @message = "hai"
  @message = "\"hello world\"って言えよ" unless params[:str] == "hello world"
  haml :index
end
