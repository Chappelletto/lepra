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
	# Создает таблицу 
	@db.execute 'CREATE TABLE if not exists "Posts" (
	"id"	INTEGER,
	"created_date"	DATE,
	"content"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
)'

	@db.execute 'CREATE TABLE if not exists "Comments" (
	"id"	INTEGER,
	"created_date"	DATE,
	"content"	TEXT,
	"post_id" INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT)
)'
end

get '/' do
	#Выбираем посты из бд

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

#обработчик гет запроса (браузер получает страницу с сервера)
get '/new' do
  erb :new
end

#обработчик пост запроса (браузер отправляет данные на сервер)
post '/new' do
	#Получаем переменную из пост запроса
  	content = params[:content]

  if content.length <= 0
  	@error = 'Type text'
  	return erb :new
  end

  #Сохранение данных в бд
  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  #Перенаправление на главную страницу
  redirect to '/'

  erb "You typed: #{content}"
end

#Вывод информации о посте
get '/details/:post_id' do
	#получаем переменную из URl
	post_id = params[:post_id]

	#получаем список постов (у нас будет один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	
	#выбираем этот один пост в переменную @row
	@row = results[0]

	#возвращаем представление 
	erb :details
end

#Обработчик пост запроса .details
post '/details/:post_id' do
	#получаем переменную из URl
	post_id = params[:post_id]
	#Получаем переменную из пост запроса
	content = params[:content]

	erb "You typed comment #{content} fro post #{post_id}"
end