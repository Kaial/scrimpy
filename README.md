Scrimpy is a lightweight blog engine based on Adam Wiggins Scanty (https://github.com/adamwiggins/scanty)
I used it as a way to learn ruby and hack around with mongodb and heroku. If you would like to use it yourself
you will have to change the blog config struct at the top of main.rb

    $Blog = OpenStruct.new(
        :title => 'your blog title',
        :author => 'yourname',					
        :url_base => 'yoururl.com',
        :admin_password => 'passwordusedtoauthenticate',
        :admin_cookie_key => 'blog_admin',
        :admin_cookie_val => 'asecretcookiekeyusedforauth',
        :mongo_uri => 'fulluripathtoyourblog',
        :mongo_db => 'thenameofyourblogdb',
        :mongo_default_collection => 'thecollectionyourblogdataisin')
        
The blog uses these gems
sinatra
haml
mongo
redcarpet
I deploy mine to heroku, however you can also run it locally by running 'ruby -rubygems main.rb' (assuming you have a database setup)