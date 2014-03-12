#post.rb this is the post class
#it handles all the logic with retrieving posts
require 'time'
require 'mongo'
require 'redcarpet'
require 'ostruct'

class Post
	@@MarkDown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)			
	@@BlogCollection = Mongo::Connection.from_uri($Blog['mongo_uri']).db($Blog['mongo_db']).collection($Blog['mongo_default_collection'])
	attr_accessor :title, :created, :body, :tags, :author, :slug
	
	def initialize (title,created,body,tags,author,slug)
		@title = title
		@created = created.getutc
		@body = body
		@tags = tags
		@author = author
		@slug = slug		
	end	
	
	def Post.build_from_document(doc)
		Post.new(doc["title"], doc["created"], doc["body"], doc["tags"], doc["author"], doc["slug"])
	end
	
	def default_initialize
		@title = "Enter Title"
		@created = Time.now.utc
		@body = "Enter body markdown supported"
		@tags = ["new"]
		@author = $Blog['author']
	end
	#crud operations	
	def Post.del(slug)
	end
	
	def Post.list_all()
		docs = @@BlogCollection.find()
		posts = []		
		docs.each do |doc|
			posts.push(Post.build_from_document(doc))
		end
		posts.sort { |a,b| b.created <=> a.created }
	end
	
	def save
		doc = @@BlogCollection.find_one("slug" => slug)
		if doc
			#update it
			doc["body"] = body
			doc["tags"] = tags
			doc["title"] = title
			doc["slug"] = Post.make_slug(title)
			@@BlogCollection.update({"_id" => doc["_id"]},doc)
		else
			#make a new one
			doc = {"title" =>  title, "created" => created, "body" => body,"tags" => tags, "author" => author, "slug" => slug}
			@@BlogCollection.insert(doc)
		end				
	end
	
	def Post.find(slug)		
		doc = @@BlogCollection.find_one("slug" => slug)
		Post.build_from_document(doc)
	end
			
	def Post.find_all_by_tag(tag)
		docs = @@BlogCollection.find("tags" => tag)
		posts = []		
		docs.each do |doc|
			posts.push(Post.build_from_document(doc))
		end
		posts
	end
	########	
	
	def self.make_slug(title)
		title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
	end
	
	def body_html
		to_html(body)
	end
	
	def url
		d = created
		"/past/#{d.year}/#{d.month}/#{d.day}/#{slug}"
	end
	
	def full_url
		Blog['url_base'].gsub(/\/$/, '') + url
	end
	
	def summary
		@summary ||= body.match(/(.{200}.*?\n)/m)
		@summary || body
	end
	
	def summary_html
		#summary blurb html
		to_html(summary.to_s)
	end
	
	def linked_tags
		accum = []
		tags.each do |tag|
			accum.push("<a href=\"/past/tags/#{tag}\"> #{tag}</a>")
		end
		accum
	end	
	
	def to_html(text)
		@@MarkDown.render(text)
	end
end
