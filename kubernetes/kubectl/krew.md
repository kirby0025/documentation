## Krew

Krew is a plugin management tool for kubectl

### Install

```bash
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```
- Add .krew/bin to $PATH

### Autocompletion

```bash
mkdir -p ~/.oh-my-zsh/custom/completions
chmod -R 755 ~/.oh-my-zsh/custom/completions
cd ~/.oh-my-zsh/custom/completions
wget https://github.com/ahmetb/kubectx/blob/master/completion/_kubens.zsh
wget https://github.com/ahmetb/kubectx/blob/master/completion/_kubectx.zsh
echo "fpath=($ZSH/custom/completions $fpath)" >> ~/.zshrc
```

### Install kubectl plugin

```bash
kubectl krew install ctx ns
```
