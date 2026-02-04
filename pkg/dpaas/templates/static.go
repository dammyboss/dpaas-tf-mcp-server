package templates

import _ "embed"

//go:embed static/context.tf
var ContextTf string

//go:embed static/pre_commit_config.yaml
var PreCommitConfig string

//go:embed static/versions_root.tf
var VersionsRootTf string

//go:embed static/versions_test.tf
var VersionsTestTf string

//go:embed static/null_label_vars_part_a.tf
var NullLabelVarsPartA string

//go:embed static/null_label_vars_part_b.tf
var NullLabelVarsPartB string

//go:embed static/gitignore
var Gitignore string
