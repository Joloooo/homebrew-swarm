class Swarm < Formula
  include Language::Python::Virtualenv

  desc "Autonomous LLM-based agent for automated web-application analysis"
  homepage "https://github.com/Joloooo/swarm"
  url "https://github.com/Joloooo/swarm/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "74c4868fb704a051ce69acf04bd7a5e404ebc6810f7497fe35dbfab05305e8f4"
  license "MIT"
  head "https://github.com/Joloooo/swarm.git", branch: "main"

  depends_on "nmap"
  depends_on "python@3.12"
  depends_on "tmux"

  def install
    # swarm's dependency tree (langchain, langgraph, pydantic, playwright,
    # reportlab, ...) is far too large to vendor as Homebrew resources, and
    # the built-in virtualenv helpers force --no-deps/--no-binary. So we build
    # a plain venv and let pip resolve dependencies from PyPI wheels.
    system formula_opt_bin("python@3.12")/"python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--no-cache-dir", buildpath
    bin.install_symlink libexec/"bin/swarm"
    bin.install_symlink libexec/"bin/swarmattacker"
  end

  def caveats
    <<~EOS
      swarm drives a headless browser via Playwright. Install the Chromium
      runtime once with:
        #{libexec}/bin/playwright install chromium

      Optional pentest tools some agents shell out to (nmap and tmux are
      installed automatically):
        brew install gobuster sqlmap nikto

      Set your LLM provider key before running, e.g.:
        export ANTHROPIC_API_KEY=...   # or OPENAI_API_KEY=...
    EOS
  end

  test do
    assert_match(/swarm|usage|Usage/i, shell_output("#{bin}/swarm --help 2>&1"))
  end
end
