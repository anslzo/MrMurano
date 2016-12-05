require 'MrMurano/Product'
require 'terminal-table'

command 'product device list' do |c|
  c.syntax = %{mr product device list [options]}
  c.summary = %{List serial numbers for a product}

  c.option '--offset NUMBER', Integer, %{Offset to start listing at}
  c.option '--limit NUMBER', Integer, %{How many devices to return}

  c.action do |args,options|
    options.default :offset=>0, :limit=>50

    prd = MrMurano::Product.new
    data = prd.list(options.offset, options.limit)
    busy = data.map{|row| [row[:sn], row[:status], row[:rid]]}
    table = Terminal::Table.new :rows => busy, :headings => ['SN', 'Status', 'RID']
    say table
  end
end

command 'product device enable' do |c|
  c.syntax = %{mr product device enable <sn>}
  c.summary = %{Enable a serial number; Creates device in Murano}
  c.description = %{Enables a serial number, creating the digial shadow in Murano.

NOTE: This opens the 24 hour activation window.  If the device does not make
the activation call within this time, it will need to be enabled again.
  }
  c.option '--name NAME', String, %{A name for this device.}

  c.action do |args,options|
    prd = MrMurano::Product.new
    pod = MrMurano::Product1PDevice.new
    if args.count > 0 then
      res = prd.enable(args[0])
      if res[:rid] then
        name = options.name
        name = args[0] unless options.name
        pp pod.rename(args[0], name, res[:rid])
      end
    else
      prd.error "Missing a serial number to enable"
    end
  end
end

command 'product device batchenable' do |c|
  c.syntax = %{mr product device batchenable <file of identifiers>]}
  c.summary = %{Enable devices; Creates devices in Murano}
  c.description = %{Enables serial numbers, creating the digial shadow in Murano.

NOTE: This opens the 24 hour activation window.  If the device does not make
the activation call within this time, it will need to be enabled again.
  }

  c.action do |args,options|
    prd = MrMurano::Product.new
    pod = MrMurano::Product1PDevice.new
    fname = args.shift
    if fname.nil? then
      prd.error "Missing identifiers file"
    else
      File.open(fname) do |io|
        io.each_line do |line|
          line.strip!
          unless line.empty? then
            snid, name = line.split(',')
            snid.strip!
            name = snid unless name.nil?
            res = prd.enable(snid)
            if res[:rid] then
              pod.rename(snid, name, res[:rid])
            end
          end
        end
      end
    end
  end
end


command 'product device activate' do |c|
  c.syntax = %{mr product device activate <sn>}
  c.summary = %{Activate a serial number, retriving its CIK}
  c.description = %{Activates a serial number.

Generally you should not use this.  Instead the device should make the activation
call itself and save the CIK token.  Its just that sometimes when building a
proof-of-concept it is just easier to hardcode the CIK.

Note that you can only activate a device once.  After that you cannot retrive the
CIK again.
}

  c.action do |args,options|
    prd = MrMurano::ProductSerialNumber.new
    if args.count < 1 then
      prd.error "Serial number missing"
      return
    end
    sn = args.first

    prd.outf prd.activate(sn)

  end
end

alias_command 'sn list', 'product device list'
alias_command 'sn enable', 'product device enable'
alias_command 'sn activate', 'product device activate'

#  vim: set ai et sw=2 ts=2 :
