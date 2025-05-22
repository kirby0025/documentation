## Auto-generated documentation for Terraform module

### Installation de terraform-docs

```bash
cd /tmp/
wget https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-linux-amd64.tar.gz
tar xf terraform-docs-v0.16.0-linux-amd64.tar.gz
sudo mv terraform-docs /usr/local/bin
```

## Hook pre-commit

```bash
cat << EOF > .git/hooks/pre-commit
#!/bin/sh

# Keep module docs up to date
target_dir=$(find . -type f -name "*.tf" -not -path "*/.terraform/*" -exec dirname {} \; | sort -u)
for d in ${target_dir}; do
  if terraform-docs -c .terraform-docs.yml --output-file README.md $d ; then
    git add "./$d/README.md"
  fi
done
EOF
