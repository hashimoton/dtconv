# coding: utf-8

require "open3"

Encoding.default_external = 'utf-8'

class CommandHelper

  attr_accessor :output, :error, :exit_code
  
  def initialize(exe_path)
    @exe = exe_path
  end
  
  def run(arg_line, input = '')
    command = "#{@exe} #{arg_line}"
    puts "COMMAND=[#{command}]"
    puts "INPUT=[#{input}]"
    @output, @error, status = Open3.capture3(command , stdin_data: input)
    puts "OUTPUT=[#{@output}]"
    $stderr.puts "ERROR=[#{@error}]"
    @exit_code = status.to_i
  end
  
end


# EOF

