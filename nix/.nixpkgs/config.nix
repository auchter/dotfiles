{
    packageOverrides = pkgs: with pkgs; {
        ncmpcpp = ncmpcpp.override {
            outputsSupport = true;
            clockSupport = true;
        };
        polybar = polybar.override {
            mpdSupport = true;
            alsaSupport = true;
        };
    };

    allowUnfree = true;
}

