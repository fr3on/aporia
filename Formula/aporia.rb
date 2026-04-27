class Aporia < Formula
  desc "Adaptive, high-performance Zsh theme for professionals"
  homepage "https://github.com/fr3on/aporia"
  url "https://github.com/fr3on/aporia/archive/refs/tags/1.1.4.tar.gz"
  sha256 "799a57126b5955388865b6a22f2f3ebd7a63503679e6d9fdd3b71c75a68f02c6"
  license "MIT"

  def install
    # Install the theme and plugin files to the share directory
    share.install "aporia.zsh-theme"
    share.install "aporia.plugin.zsh"
    
    # Install the first-party plugins directory
    share.install "plugins" if File.directory? "plugins"
    
    # Also install auxiliary scripts
    share.install "uninstall.sh"

    # Create the "aporia-setup" helper script
    (bin/"aporia-setup").write <<~EOS
      #!/bin/zsh
      # Aporia Auto-Setup Helper
      ZSHRC="$HOME/.zshrc"
      THEME_PATH="#{opt_share}/aporia.zsh-theme"
      SOURCE_LINE="source $THEME_PATH"

      if grep -qF "$THEME_PATH" "$ZSHRC" 2>/dev/null; then
        echo "Aporia is already configured in $ZSHRC"
      else
        echo "Adding Aporia to $ZSHRC..."
        printf '\\n# Aporia Zsh Theme\\n%s\\n' "$SOURCE_LINE" >> "$ZSHRC"
        echo "Successfully activated! Please restart your terminal or run: source ~/.zshrc"
      fi
    EOS
    chmod 0755, bin/"aporia-setup"
    
  end

  def caveats
    <<~EOS
      Aporia has been installed! To activate it automatically, run:
        aporia-setup

      Or manually add this to your .zshrc:
        source #{opt_share}/aporia.zsh-theme
    EOS
  end

  test do
    assert_match "aporia", shell_output("zsh -c 'source #{opt_share}/aporia.zsh-theme && echo $ZSH_THEME_NAME'").strip
  end
end
