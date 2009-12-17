require 'spec/autorun'
require 'sane'
require_rel './after'

describe After do

  def go how_many = 1
     pid = Process.spawn "ruby ./sleep.rb #{how_many}"
  end

  it "should be able to grab the right pid" do
     pid = go
     a = After.find_pids('sleep')
     a[0].should == pid
  end

  it "should immediately return if the other process doesn't exist" do
    a = After.find_pids('non existent process')
    assert a.empty?
  end

  it "should wait for another process to terminate" do
    go
    start = Time.now
    After.find_and_wait_for('sleep')
    assert (Time.now - start) > 0.5 
  end

  it "should work if there are several available" do
    go 1
    go 2
    go 3
    start = Time.now
    After.find_and_wait_for('sleep')
    assert (Time.now - start) > 2     
  end

  it "should split the commands up right--if necessary"

end