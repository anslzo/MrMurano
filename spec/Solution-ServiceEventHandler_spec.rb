require 'MrMurano/version'
require 'MrMurano/Solution-Services'
require 'tempfile'
require '_workspace'

RSpec.describe MrMurano::EventHandler do
  include_context "WORKSPACE"
  before(:example) do
    $cfg = MrMurano::Config.new
    $cfg.load
    $cfg['net.host'] = 'bizapi.hosted.exosite.io'
    $cfg['solution.id'] = 'XYZ'

    @srv = MrMurano::EventHandler.new
    allow(@srv).to receive(:token).and_return("TTTTTTTTTT")
  end

  it "initializes" do
    uri = @srv.endPoint('/')
    expect(uri.to_s).to eq("https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/")
  end

  it "lists" do
    body = {:items=>[{:id=>"9K0",
             :name=>"debug",
             :alias=>"XYZ_debug",
             :solution_id=>"XYZ",
             :service=>"device",
             :event=>"datapoint",
             :created_at=>"2016-07-07T19:16:19.479Z",
             :updated_at=>"2016-09-12T13:26:55.868Z"}],
            :total=>1}
    stub_request(:get, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(body: body.to_json)

    ret = @srv.list()
    expect(ret).to eq(body[:items])
  end

  it "fetches, with header" do
    body = {:id=>"9K0",
             :name=>"debug",
             :alias=>"XYZ_debug",
             :solution_id=>"XYZ",
             :service=>"device",
             :event=>"datapoint",
             :created_at=>"2016-07-07T19:16:19.479Z",
             :updated_at=>"2016-09-12T13:26:55.868Z",
             :script=>%{--#EVENT device datapoint
             -- lua code is here
    function foo(bar)
      return bar + 1
    end
    }
    }
    stub_request(:get, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/9K0").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(body: body.to_json)

    ret = @srv.fetch('9K0')
    expect(ret).to eq(body[:script])
  end

  it "fetches, with header into block" do
    body = {:id=>"9K0",
             :name=>"debug",
             :alias=>"XYZ_debug",
             :solution_id=>"XYZ",
             :service=>"device",
             :event=>"datapoint",
             :created_at=>"2016-07-07T19:16:19.479Z",
             :updated_at=>"2016-09-12T13:26:55.868Z",
             :script=>%{--#EVENT device datapoint
             -- lua code is here
    function foo(bar)
      return bar + 1
    end
    }
    }
    stub_request(:get, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/9K0").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(body: body.to_json)

    ret = nil
    @srv.fetch('9K0') { |sc| ret = sc }
    expect(ret).to eq(body[:script])
  end

  it "fetches, without header" do
    body = {:id=>"9K0",
             :name=>"debug",
             :alias=>"XYZ_debug",
             :solution_id=>"XYZ",
             :service=>"device",
             :event=>"datapoint",
             :created_at=>"2016-07-07T19:16:19.479Z",
             :updated_at=>"2016-09-12T13:26:55.868Z",
             :script=>%{-- lua code is here
function foo(bar)
  return bar + 1
end
}
    }
    stub_request(:get, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/9K0").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(body: body.to_json)

    ret = @srv.fetch('9K0')
    expect(ret).to eq(%{--#EVENT device datapoint
-- lua code is here
function foo(bar)
  return bar + 1
end
})
  end

  it "removes" do
    stub_request(:delete, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/9K0").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(body: "")

    ret = @srv.remove('9K0')
    expect(ret).to eq({})
  end

  it "uploads over old version" do
    stub_request(:put, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/XYZ_data_datapoint").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(body: "")

    Tempfile.open('foo') do |tio|
      tio << %{-- lua code is here
    function foo(bar)
      return bar + 1
    end
      }
      tio.close

      ret = @srv.upload(tio.path, {:id=>"9K0",
                                   :service=>'data',
                                   :event=>'datapoint',
                                   :solution_id=>"XYZ",
      })
      expect(ret)
    end
  end

  it "uploads when nothing is there" do
    stub_request(:put, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/XYZ_device_datapoint").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(status: 404)
    stub_request(:post, "https://bizapi.hosted.exosite.io/api:1/solution/XYZ/eventhandler/").
      with(:headers=>{'Authorization'=>'token TTTTTTTTTT',
                      'Content-Type'=>'application/json'}).
      to_return(body: "")

    Tempfile.open('foo') do |tio|
      tio << %{-- lua code is here
    function foo(bar)
      return bar + 1
    end
      }
      tio.close

      ret = @srv.upload(tio.path, {:id=>"9K0",
                                   :solution_id=>"XYZ",
                                   :service=>"device",
                                   :event=>"datapoint",
      })
      expect(ret)
    end

  end

  context "compares" do
    before(:example) do
      @iA = {:id=>"9K0",
            :name=>"debug",
            :alias=>"XYZ_debug",
            :solution_id=>"XYZ",
             :service=>"device",
             :event=>"datapoint",
            :created_at=>"2016-07-07T19:16:19.479Z",
            :updated_at=>"2016-09-12T13:26:55.868Z"}
      @iB = {:id=>"9K0",
            :name=>"debug",
            :alias=>"XYZ_debug",
            :solution_id=>"XYZ",
             :service=>"device",
             :event=>"datapoint",
            :created_at=>"2016-07-07T19:16:19.479Z",
            :updated_at=>"2016-09-12T13:26:55.868Z"}
    end
    it "both have updated_at" do
      ret = @srv.docmp(@iA, @iB)
      expect(ret).to eq(false)
    end

    it "iA is a local file" do
      Tempfile.open('foo') do |tio|
        tio << "something"
        tio.close
        iA = @iA.reject{|k,v| k == :updated_at}.merge({
          :local_path => Pathname.new(tio.path)
        })
        ret = @srv.docmp(iA, @iB)
        expect(ret).to eq(true)

        iB = @iB.merge({:updated_at=>Pathname.new(tio.path).mtime.getutc})
        ret = @srv.docmp(iA, iB)
        expect(ret).to eq(false)
      end
    end

    it "iB is a local file" do
      Tempfile.open('foo') do |tio|
        tio << "something"
        tio.close
        iB = @iB.reject{|k,v| k == :updated_at}.merge({
          :local_path => Pathname.new(tio.path)
        })
        ret = @srv.docmp(@iA, iB)
        expect(ret).to eq(true)

        iA = @iA.merge({:updated_at=>Pathname.new(tio.path).mtime.getutc})
        ret = @srv.docmp(iA, iB)
        expect(ret).to eq(false)
      end
    end
  end

  context "Lookup functions" do
    it "gets local name" do
      ret = @srv.tolocalname({ :name=>"bob" }, nil)
      expect(ret).to eq('bob.lua')
    end

    it "gets synckey" do
      ret = @srv.synckey({ :service=>'device', :event=>'datapoint' })
      expect(ret).to eq("device_datapoint")
    end

    it "gets searchfor" do
      $cfg['eventhandler.searchFor'] = %{a b c/**/d/*.bob}
      ret = @srv.searchFor
      expect(ret).to eq(["a", "b", "c/**/d/*.bob"])
    end

    it "gets ignoring" do
      $cfg['eventhandler.ignoring'] = %{a b c/**/d/*.bob}
      ret = @srv.ignoring
      expect(ret).to eq(["a", "b", "c/**/d/*.bob"])
    end

    it "raises on alias without service" do
      expect {
        @srv.mkname( {:event=>'bob'} )
      }.to raise_error %{Missing parts! {"event":"bob"}}
    end

    it "raises on alias without event" do
      expect {
        @srv.mkalias( {:service=>'bob'} )
      }.to raise_error %{Missing parts! {"service":"bob"}}
    end

    it "raises on name without service" do
      expect {
        @srv.mkalias( {:event=>'bob'} )
      }.to raise_error %{Missing parts! {"event":"bob"}}
    end

    it "raises on name without event" do
      expect {
        @srv.mkname( {:service=>'bob'} )
      }.to raise_error %{Missing parts! {"service":"bob"}}
    end
  end

  context "toRemoteItem" do
    before(:example) do
      allow(@srv).to receive(:warning)
    end

    it "reads one" do
      Tempfile.open('foo') do |tio|
        tio << %{--#EVENT device datapoint
        -- do something.
        Tsdb.write{tags={sn='1'},metrics={[data.alias]=data.value[2]}}
        }.gsub(/^\s+/,'')
        tio.close

        ret = @srv.toRemoteItem(nil, tio.path)
        expect(ret).to eq({:service=>'device',
                           :event=>'datapoint',
                           :line=>0,
                           :line_end=>3,
                           :local_path=>Pathname.new(tio.path),
                           :script=>%{--#EVENT device datapoint\n-- do something.\nTsdb.write{tags={sn='1'},metrics={[data.alias]=data.value[2]}}\n},
        })
      end
    end

    it "skips all when no header found" do
      Tempfile.open('foo') do |tio|
        tio << %{
        -- do something.
        Tsdb.write{tags={sn='1'},metrics={[data.alias]=data.value[2]}}
        }.gsub(/^\s+/,'')
        tio.close

        ret = @srv.toRemoteItem(nil, tio.path)
        expect(ret).to eq(nil)
      end
    end

    it "skips junk at begining" do
      Tempfile.open('foo') do |tio|
        tio << %{
        -- do something.
        --#EVENT device datapoint
        Tsdb.write{tags={sn='1'},metrics={[data.alias]=data.value[2]}}
        }.gsub(/^\s+/,'')
        tio.close

        ret = @srv.toRemoteItem(nil, tio.path)
        expect(ret).to eq({:service=>'device',
                           :event=>'datapoint',
                           :line=>1,
                           :line_end=>3,
                           :local_path=>Pathname.new(tio.path),
                           :script=>%{--#EVENT device datapoint\nTsdb.write{tags={sn='1'},metrics={[data.alias]=data.value[2]}}\n},
        })
      end
    end

  end

end
#  vim: set ai et sw=2 ts=2 :
