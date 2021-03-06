require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_master_exists? db, name
  db.execute('select * from Masters where name=?', [name]).length > 0
end

def seed_db db, masters
  masters.each do |master|
    if !is_master_exists? db, master
      db.execute 'insert into Masters (name) values (?)', [master]
    end
  end
end

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

before do 
  db = get_db
  @masters = db.execute 'select * from Masters'
end

configure do
  db = get_db

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Users"
	(
	  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
	  "username" TEXT,
	  "phone" TEXT,
	  "datetime" TEXT,
	  "master" TEXT,
	  "colorpicker" TEXT
	)'

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Masters"
	(
	  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
	  "name" TEXT
	  
	)'

  seed_db db, ['Jessie Pen', 'Walter Clone', 'Messi Roe', 'Niko Boomdoo']
end

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"     
end

get '/about' do
  @error = 'ERROR!'
  erb :about
end

get '/visit' do
  db = get_db

  @barbers = db.execute 'select * from Users order by id desc'

  erb :visit
end

post '/visit' do
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @master = params[:master]
  @colorpicker = params[:colorpicker]

  h = {:username => 'Type name', 
  	   :phone => 'Type phone', 
  	   :datetime => 'Type date and time'} 

  @error = h.select {|k,_| params[k] == ""}.values.join(", ")
  if @error != ''
  	return erb :visit
  end


db = get_db
  db.execute 'insert into
	Users
	(
	  username,
	  phone,
	  datetime,
	  master,
	  colorpicker
	)
	values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @master, @colorpicker]

	erb "<h2>Thanks, We wait you in our BarberShop!</h2>"
end


get '/message' do
  erb :message
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @email = params[:email]
  @message = params[:message]

   h1 = {:email => 'Type email', 
  	   :message => 'Type message'} 

  @error = h1.select {|k,_| params[k] == ""}.values.join(", ")
  if @error != ''
  	return erb :contacts
  end
 
  a = File.open './public/contacts.txt', 'a'
  a.write "Email: #{@email}, message: #{@message}"
  a.close

  @title = 'Thank you!'
  @message = "Your message will be sending, we answer for you email: #{@email}"
  erb :message
end

get '/showusers' do
  db = get_db

  @results = db.execute 'select * from Users order by id desc'

  erb :showusers
end



