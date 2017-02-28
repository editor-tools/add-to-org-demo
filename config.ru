require './my_app'

AddToOrg.views_dir = File.expand_path("./views", File.dirname(__FILE__))

run AddToOrg::App
