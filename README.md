# awsumfa
AWS CLI helper for assume role and use MFA.
This can be especially helpful when you have multiple roles and/or accounts.

# Requirements
* Just `/bin/bash`
* You can install [`gum`](https://github.com/charmbracelet/gum) to have cool cli interactive selector

# Installation
```
curl https://raw.githubusercontent.com/runwuf/awsumfa/main/awsumfa.bash > ~/awsumfa.bash
```

# Getting Started
* Update your MFA ARN in `AWS_MFAARN` of `awsumfa.bash`
* Edit the sample `credentials` to add your roles and accounts then place it in `~/.aws/`
* source this bash script or add it to your `~/.bashrc`
```
source ~/awsumfa.bash
```

# Usage
`awsmfa ${role_name}` - choose the role defined in `credentials` to assume to.  `gum` is required without providing `${role_name}`.

`awsec2ls` - list ec2 instances in a nice format.

`awsec2 ${instance_id}` - ssm into an ec2 instance.

`installawstools` - install `aws-ssm-ec2-proxy-command.sh` makes `scp` easy to work with ec2 instances.


