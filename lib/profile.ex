defmodule Profile do
  import ExProf.Macro

  def run do
    profile do
      TwitchDiscovery.Index.index
    end
  end

  # def go do
  #   :fprof.apply(&run_test/0, [])
  #   :fprof.profile()
  #   :fprof.analyse()
  # end

  # def go do
  #   :eflame.apply(&run_test/0, [])
  # end

  def run_test, do: TwitchDiscovery.Index.index
end