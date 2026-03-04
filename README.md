# NixOS on DigitalOcean with Terraform

Terranix + deploy-rs で NixOS Droplet をデプロイ

## 前提

- Nix (flakes有効)
- DigitalOcean アカウント
- SSH キー (という名前でDigitalOceanにアップロード済み)

## 準備

```bash
# 環境変数を設定
export DIGITALOCEAN_TOKEN="dop_v1_xxxxxxxxxxxxx"
```

## インフラ作成 (Terraform)

```bash
nix run .#tf-plan
nix run .#tf-apply
```

IPアドレスを確認:

```bash
tofu output droplet_ip
```

## NixOSデプロイ

`flake.nix` の `deploy.nodes.droplet.hostname` を実際のIPアドレスに書き換えて:

```bash
deploy
```

## 構成

| ファイル | 説明 |
|---------|------|
| `flake.nix` | メインFlake定義 (NixOS + Terranix + deploy-rs) |
| `terraform/terraform.nix` | Terranix設定 (DigitalOcean Droplet作成) |
| `terraform/do-image.nix` | DigitalOceanイメージビルド設定 |
| `deploy/nixos-configurations.nix` | NixOS設定ビルダー |
| `deploy/droplet-configuration.nix` | Dropletシステム設定 |
| `deploy/openclaw.nix` | OpenClaw Gateway + sops-nix シークレット設定 |
| `deploy/deployment.nix` | deploy-rs設定 |
| `.sops.yaml` | sops 暗号化ルール (age キー設定) |
| `secrets/openclaw.yaml` | 暗号化済みシークレット |

## OpenClaw セットアップ

### 1. age キーを生成

```bash
nix shell nixpkgs#age -c age-keygen -o keys.txt
# 出力される公開鍵を .sops.yaml の &admin にコピー
```

### 2. Droplet をデプロイしてホスト鍵を取得

```bash
nix run .#tf-apply
ssh-keyscan $(tofu output -raw droplet_ip) | nix run nixpkgs#ssh-to-age
# 出力を .sops.yaml の &server にコピー
```

### 3. シークレットを暗号化

```bash
SOPS_AGE_KEY_FILE=./keys.txt nix shell nixpkgs#sops -c sops secrets/openclaw.yaml
# エディタで API キー等を入力して保存
```

### 4. NixOS をデプロイ

```bash
deploy
```

OpenClaw Gateway: `http://<DROPLET_IP>:18789`

## 削除

```bash
nix run .#tf-destroy
```
