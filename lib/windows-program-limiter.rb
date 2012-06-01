require 'rubygems' # for now...
require 'os'
if OS.windows?
  require 'ruby-wmi' # wow not even pretended linux compat. yet
end
require 'sane'

require 'jruby-swing-helpers/lib/swing_helpers'
require 'jruby-swing-helpers/lib/parse_template'

include SwingHelpers # JFrame

class Watcher

  def self.find_all_pids_matching_strings(many_args)

    procs_by_pid = {}
    if OS.windows?
      procs = WMI::Win32_Process.find(:all)
      for proc in procs
        procs_by_pid[proc.ProcessId] = ("% 20s" % proc.Name.to_s) + ' ' + proc.CommandLine.to_s
      end
    else
      a = `ps -ef` # my linux support isn't very good yet...
      a.lines.to_a[1..-1].each{|l| pid = l.split(/\s+/)[1]; procs_by_pid[pid.to_i] = l}
    end
	
	#p procs_by_pid

    good_pids = []
    for pid, description in procs_by_pid
       for arg in many_args
        if description.downcase.contain?(arg.downcase)
		   p 'comparing',pid,Process.pid
	      next if pid == Process.pid
          good_pids << [pid, description]
          pps 'found', "% 5d" % pid, description
        end
	  end
    end
    good_pids # actually offending pids
  end
  
  def self.poll_forever args
    loop {
    if (got=find_all_pids_matching_strings(args)).length > 0
	  @frame ||= begin
	    frame = ParseTemplate::JFramer.new
		setup_string = %!"I caught you cheating\! #{got.join(' ')}"!
		puts setup_string
		frame.parse_setup_string setup_string
		frame.maximize
        frame.always_on_top=true		
		frame.after_closed {
		  p 'closed'
		  @frame = nil # let it just show up again to annoy LOL
		}
		frame
	   end
	  
	else
	  @frame.close if @frame # race condition here LOL
	  puts 'nothing found...'
	end
	sleep 10
	}
  end

end
