class Potter < Formula
  desc "Lightweight terminal Pomodoro timer with tasks, focus history and music"
  homepage "https://github.com/ZehraDuymaz/potter"
  url "https://github.com/ZehraDuymaz/potter/archive/refs/tags/v0.5.3.tar.gz"
  sha256 "62a49cee7a1aa947e39b2a52e6a84e4bdf062e294850e7807fc17e4236967141"
  license "GPL-3.0-or-later"
  head "https://github.com/ZehraDuymaz/potter.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build
  depends_on "tomlplusplus"

  # FTXUI (the terminal UI library) is downloaded here, because Homebrew
  # builds without internet access for CMake.
  resource "ftxui" do
    url "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz"
    sha256 "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71"
  end

  def install
    (buildpath/"ftxui").install resource("ftxui")
    system "cmake", "-S", ".", "-B", "build",
           "-DFETCHCONTENT_SOURCE_DIR_FTXUI=#{buildpath}/ftxui",
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
