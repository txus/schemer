require 'rspec'

require 'parslet'
require 'parslet/rig/rspec'

require 'schemer'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].entries.each { |file| require file }
