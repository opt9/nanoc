# encoding: utf-8

class Nanoc::CLI::Commands::CreateSiteTest < Nanoc::TestCase

  def test_create_site_with_existing_name
    Nanoc::CLI.run %w( create_site foo )
    assert_raises(::Nanoc::Errors::GenericTrivial) do
      Nanoc::CLI.run %w( create_site foo )
    end
  end

  def test_can_compile_new_site
    Nanoc::CLI.run %w( create_site foo )

    FileUtils.cd('foo') do
      compile_site_here
    end
  end

  def test_new_site_has_correct_stylesheets
    Nanoc::CLI.run %w( create_site foo )
    FileUtils.cd('foo') do
      compile_site_here

      assert File.file?('output/stylesheet.css')
      assert File.file?('output/index.html')
      assert_match(/\/stylesheet.css/, File.read('output/index.html'))
    end
  end

end
