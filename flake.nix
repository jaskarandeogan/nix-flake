{
  description = "Starter development environment with Supabase, Vercel, and GitHub CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Core CLIs
            supabase-cli
            nodePackages.vercel
            gh
            
            # Supporting tools
            nodejs_20
            yarn
            git
            jq
            curl
          ];

          shellHook = ''
            # Colors
            RED='\033[0;31m'
            GREEN='\033[0;32m'
            BLUE='\033[0;34m'
            YELLOW='\033[1;33m'
            NC='\033[0m' # No Color

            echo -e "''${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
            echo -e "''${BLUE}🚀 Development Environment Starter''${NC}"
            echo -e "''${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
            echo ""

            # Create .dev-env directory for tracking
            mkdir -p .dev-env

            # Check if first-time setup is needed
            FIRST_TIME_FILE=".dev-env/.initialized"

            if [ ! -f "$FIRST_TIME_FILE" ]; then
              echo -e "''${YELLOW}📋 First-time setup detected!''${NC}"
              echo ""
              
              read -p "Run interactive setup for Supabase, Vercel, GitHub, and Frontend? (Y/n): " RUN_SETUP
              RUN_SETUP=''${RUN_SETUP:-Y}
              
              if [[ $RUN_SETUP =~ ^[Yy]$ ]]; then
                echo ""
                # Run setup scripts
                bash ${./setup-scripts/supabase-init.sh}
                echo ""
                bash ${./setup-scripts/vercel-init.sh}
                echo ""
                bash ${./setup-scripts/github-init.sh}
                echo ""
                # Frontend code already exists in this repo, so setup is optional
                bash ${./setup-scripts/frontend-init.sh}
                
                # Install dependencies if package.json exists
                if [ -f "package.json" ]; then
                  echo ""
                  echo -e "''${YELLOW}📦 Installing project dependencies...''${NC}"
                  if command -v yarn &> /dev/null; then
                    yarn install
                  elif command -v npm &> /dev/null; then
                    npm install
                  else
                    echo -e "''${RED}⚠️  No package manager found. Install yarn or npm.''${NC}"
                  fi
                fi
                
                # Mark as initialized
                touch "$FIRST_TIME_FILE"
                echo ""
                echo -e "''${GREEN}✅ Environment fully initialized!''${NC}"
              else
                echo -e "''${YELLOW}⏭️  Skipping setup. Run 'setup-all' when ready.''${NC}"
                touch "$FIRST_TIME_FILE"
              fi
            else
              echo -e "''${GREEN}✅ Environment ready''${NC}"
            fi

            # Helper functions and aliases
            setup-all() {
              rm -f .dev-env/.initialized
              exec $SHELL
            }

            setup-supabase() {
              bash ${./setup-scripts/supabase-init.sh}
            }

            setup-vercel() {
              bash ${./setup-scripts/vercel-init.sh}
            }

            setup-github() {
              bash ${./setup-scripts/github-init.sh}
            }

            setup-frontend() {
              bash ${./setup-scripts/frontend-init.sh}
            }

            verify-edge-function() {
              bash ${./scripts/verify-edge-function.sh}
            }

            export -f setup-all setup-supabase setup-vercel setup-github setup-frontend verify-edge-function

            # Convenient aliases
            alias supabase-dev="supabase start"
            alias supabase-stop="supabase stop"
            alias deploy="vercel --prod"
            alias dev="yarn dev"

            echo ""
            echo -e "''${BLUE}📦 Available commands:''${NC}"
            echo "  setup-all        : Re-run all setup scripts"
            echo "  setup-supabase   : Run Supabase setup only"
            echo "  setup-vercel     : Run Vercel setup only"
            echo "  setup-github     : Run GitHub setup only"
            echo "  setup-frontend   : Initialize frontend project"
            echo "  verify-edge-function : Verify edge function structure"
            echo ""
            echo "  supabase-dev     : Start local Supabase"
            echo "  supabase-stop    : Stop local Supabase"
            echo "  dev              : Start Vite dev server (recommended for local)"
            echo "  vercel dev       : Start Vercel dev server (for Vercel features)"
            echo "  deploy           : Deploy to Vercel production"
            echo ""
            echo -e "''${GREEN}💡 Tip: Your environment is reproducible. Share this flake!''${NC}"
            echo -e "''${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
            echo ""
          '';
        };
      }
    );
}