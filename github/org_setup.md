# GitHub Organization Setup

1. Create a new GitHub organization: `<GITHUB_ORG>`
2. Invite users:
   - engineerA@infobell.com
   - engineerB@infobell.com
3. Create two private repositories:
   - `aether-platform-code`
   - `aether-k8s-manifests`
4. Set branch protection rules:
   - Require PR review before merge
   - Require status checks to pass
   - Restrict force pushes and deletions
5. Add deploy keys or GitHub Actions secrets as needed for ArgoCD access.
