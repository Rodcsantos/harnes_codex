# WSL Development Baseline

## Windows
Verifique estado com: wsl --status e wsl --list --verbose.

## Ubuntu/WSL
Baseline de pacotes:
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential ca-certificates curl wget git unzip zip jq ripgrep fd-find tree htop procps lsof net-tools dnsutils openssh-client sqlite3

Prefira código no filesystem Linux, por exemplo ~/code, ~/src ou ~/projects, para evitar custo de I/O e diferenças de permissões em workloads Linux.

Configure Git e SSH dentro do WSL. Não copie chaves privadas para o repositório.

O stack Codex/eficiência é instalado por scripts/install-codex-efficient-stack.sh.

Validação básica: codex --version; git --version; python3 --version; rg --version; depois codex-efficient-doctor.