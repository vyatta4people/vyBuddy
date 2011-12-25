require File.expand_path('../../../config/environment', __FILE__)

VyattaHost.all.each {|vh| puts vh.hostname}
