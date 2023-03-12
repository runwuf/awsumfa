AWS_MFAARN=arn:aws:iam::????????????:mfa/userid
AWS_PROMPT="\u@\h \W\[\033[36m\] [awsumfa:\$AWS_PROFILE]\[\033[00m\] $ "

# this is a hack for awscli issue ignores AWS_PROFILE when AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are set
alias aws='aws --profile ${AWS_PROFILE}'

function installawstools() {
HOMEBREW_NO_AUTO_UPDATE=1 brew install jq
curl https://raw.githubusercontent.com/qoomon/aws-ssm-ec2-proxy-command/master/aws-ssm-ec2-proxy-command.sh > ~/.ssh/aws-ssm-ec2-proxy-command.sh
# awscli profile hack needs to be injected to aws-ssm-ec2-proxy-command.sh
sed -i '' '34i\
alias aws="aws --profile ${AWS_PROFILE}"\
' ~/.ssh/aws-ssm-ec2-proxy-command.sh

chmod 755 ~/.ssh/aws-ssm-ec2-proxy-command.sh
cat >> ~/.ssh/config << EOF
host i-* mi-*
  IdentityFile ~/.ssh/id_rsa
  ProxyCommand ~/.ssh/aws-ssm-ec2-proxy-command.sh %h %r %p ~/.ssh/id_rsa.pub
  StrictHostKeyChecking no
EOF
}

function awssetenv() {
[ "$#" -eq 0 ] && ACCOUNT=$(cat ~/.aws/credentials | grep "\[*\]" | awk '{print substr($0, 2, length($0) - 2)}' | gum choose) || ACCOUNT=$1
printf "Switching to [$ACCOUNT] account...\n"
export AWS_PROFILE=$ACCOUNT
export PS1=$AWS_PROMPT
}

function awsec2ls() {
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress,PrivateDnsName:PrivateDnsName,State:State.Name,Name:Tags[?Key==`Name`]|[0].Value}' --output table
}

function awsec2portforward {
eval "aws ssm start-session --target $1 --document-name AWS-StartPortForwardingSession --parameters 'portNumber=$2,localPortNumber=$3'"
}

function awsec2 {
aws ssm start-session --target $1
}

function awsreset {
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_CREDENTIAL_EXPIRATION
}

function awsmfa {
awsreset
awssetenv default
[ "$#" -eq 1 ] && TOKEN=$1 || read -p "Please enter your MFA token code: " TOKEN
AWS_CREDS=$(aws sts get-session-token --serial-number $AWS_MFAARN --token-code $TOKEN --output=json)
export AWS_ACCESS_KEY_ID=$(echo $AWS_CREDS | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDS | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $AWS_CREDS | jq -r .Credentials.SessionToken)
export AWS_CREDENTIAL_EXPIRATION=$(echo $AWS_CREDS | jq -r .Credentials.Expiration)
env | grep AWS_ | sort
printf "Your session will be expired by: ${AWS_CREDENTIAL_EXPIRATION}\n"
awssetenv
}

awssetenv default
