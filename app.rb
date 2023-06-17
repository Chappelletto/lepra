#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

#загружается каждый раз при перезагрузке страницы
before do
	#initialize db
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE if not exists "Posts" (
	"id"	INTEGER,
	"created_date"	DATE,
	"content"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);'
end

get '/' do
	erb :index
end

#обработчик гет запроса (браузер получает страницу с сервера)
get '/new' do
  erb :new
end

#обработчик пост запроса (браузер отправляет данные на сервер)
post '/new' do
  content = params[:content]

  if content.length <= 0
  	@error = 'Type text'
  	return erb :new
  end

  #Сохранение данных в бд
  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  erb "You typed: #{content}"
end