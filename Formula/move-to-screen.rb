class MoveToScreen < Formula
  desc "macOS menu bar utility for sweeping windows onto one display"
  homepage "https://github.com/wallacedrew/move-to-screen"
  url "https://github.com/wallacedrew/move-to-screen/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b09ba61a70c0cc3881b06a662514e1358d995d111dafa57d3e20c8d3a55d928d"
  license "MIT"

  depends_on :macos => :ventura
  depends_on xcode: ["16.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    app = prefix/"MoveToScreen.app"
    contents = app/"Contents"
    (contents/"MacOS").mkpath
    (contents/"Resources").mkpath

    cp ".build/release/MoveToScreen", contents/"MacOS/MoveToScreen"
    chmod 0755, contents/"MacOS/MoveToScreen"

    info_plist = (buildpath/"script/Info.plist.template").read
                 .gsub("__VERSION__", version.to_s)
    (contents/"Info.plist").write(info_plist)
    (contents/"PkgInfo").write("APPL????")
  end

  def caveats
    <<~EOS
      Launch MoveToScreen with:

          open #{opt_prefix}/MoveToScreen.app

      (or Spotlight: ⌘-Space → "MoveToScreen")

      First launch: macOS prompts for Accessibility access in
      System Settings → Privacy & Security → Accessibility.
      MoveToScreen needs this to move other apps' windows.

      To auto-start at login: click the menu bar icon → "Open at Login".

      After `brew upgrade move-to-screen`: macOS will re-prompt for
      Accessibility on next launch. macOS ties grants to the exact binary
      signature, and a fresh build always produces a new signature.
    EOS
  end

  test do
    assert_predicate prefix/"MoveToScreen.app/Contents/MacOS/MoveToScreen", :exist?
    assert_predicate prefix/"MoveToScreen.app/Contents/Info.plist", :exist?
  end
end
