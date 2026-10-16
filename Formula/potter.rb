class Potter < Formula
  desc "Lightweight terminal Pomodoro timer with tasks, focus history and music"
  homepage "https://github.com/ZehraDuymaz/potter"
  url "https://github.com/ZehraDuymaz/potter/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "07986091ae99f2180640eadb4171d391d76841e902ced9cd504dc5829e93ed49"
  license "GPL-3.0-or-later"
  head "https://github.com/ZehraDuymaz/potter.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build

  # These are downloaded here, because Homebrew builds without internet
  # access for CMake.
  # FTXUI: the terminal UI library.
  resource "ftxui" do
    url "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz"
    sha256 "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71"
  end

  # toml++, compiled into potter. Homebrew's tomlplusplus is a shared library,
  # and on macOS its parse errors can't be caught across that boundary, so a
  # broken config file would crash potter instead of being reported.
  resource "tomlplusplus" do
    url "https://github.com/marzer/tomlplusplus/archive/refs/tags/v3.4.0.tar.gz"
    sha256 "8517f65938a4faae9ccf8ebb36631a38c1cadfb5efa85d9a72e15b9e97d25155"
  end

  def install
    (buildpath/"ftxui").install resource("ftxui")
    (buildpath/"tomlplusplus").install resource("tomlplusplus")
    system "cmake", "-S", ".", "-B", "build",
           "-DFETCHCONTENT_SOURCE_DIR_FTXUI=#{buildpath}/ftxui",
           "-DCMAKE_DISABLE_FIND_PACKAGE_tomlplusplus=ON",
           "-DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=#{buildpath}/tomlplusplus",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "ctest", "--test-dir", "build", "--output-on-failure"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      For music, install mpv and yt-dlp:
        brew install mpv yt-dlp
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/potter --version")
  end
end
