require 'rubygems'
require 'sinatra'
#only set these when debuggin on the cloud9 dev server, 
#otherwise comment them out (Doesn't actually work that well)
#set :bind, "127.7.132.1"
#set :port, 8080

configure do 
	require 'ostruct'
	$Blog = OpenStruct.new(
                	:title => 'floating point park',
    				:author => 'Kyle Ceschi',					
					:url_base => 'kyleceschi.com',
					:admin_password => ENV['BLOG_PASS'],
					:admin_cookie_key => 'blog_admin',
					:admin_cookie_val => ENV['BLOG_KEY'],
					:mongo_uri => ENV['BLOG_DB_URI'],
					:mongo_db => ENV['BLOG_DB'],
					:mongo_default_collection => 'blog')
end

error do 
	e = request.env['sinatra.error']
	puts e.to_s
	puts e.backtrace.join("\n")
	"Application error"
end

helpers do
	def admin?
		request.cookies[$Blog.admin_cookie_key] == $Blog.admin_cookie_val
	end
	
	def auth
		error [401, 'Not authorized' ] unless admin?
	end
end
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'post'
get '/' do
	posts = Post.list_all
	haml :index, :locals => { :posts => posts }, :format => :html5
end

get '/past/:year/:month/:day/:slug' do
	post = Post.find(params[:slug].to_s)
	error [404, "Page not found" ] unless post
	@title = post.title
	haml :post, :locals => { :post => post }
end

get '/past' do 
	posts = Post.list_all
	@title = "Archive"
	haml :archive, :locals => { :posts => posts }
end

get '/past/tags/:tag' do
	posts = Post.find_all_by_tag(params[:tag])
	haml :archive, :locals => {:posts => posts}
end

#Admin

get '/auth' do 
	haml :auth
end

post '/auth' do
	if params[:password] == $Blog.admin_password
		response.set_cookie($Blog.admin_cookie_key,
												:value => $Blog.admin_cookie_val,
												:path => "/")
	else
		error [401, 'Not authorized']
	end
	redirect '/'
end

get '/posts/new' do
	auth
	newPostTemplate = Post.new("EnterTitle",Time.now, "body", ["new"],$Blog.author,Post.make_slug("EnterTitle"))
	haml :edit, :locals => { :post => newPostTemplate, :url => 'new' }
end

post '/posts/new' do
	auth
	post = Post.new(params[:title], Time.now, params[:body], params[:tags].split(','), $Blog.author, Post.make_slug(params[:title]) )
	post.save
	redirect post.url
end

get '/past/:year/:month/:day/:slug/edit' do 
	auth
	post = Post.find(params[:slug])
	haml :edit, :locals => { :post => post, :url => post.url + "/save" }
end

post '/past/:year/:month/:day/:slug/save' do 
	auth
	post = Post.find(params[:slug])
	error [404, "Page not found"] unless post
	post.title = params[:title]
	post.tags = params[:tags].split(',')
	post.body = params[:body]
	post.save
	redirect post.url
end
