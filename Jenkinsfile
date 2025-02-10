pipeline {
    agent any
    stages {
        stage('Test SSH Key') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'github_key', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                    eval $(ssh-agent -s)
                    ssh-add $SSH_KEY
                    ssh -T git@github.com
                    '''
                }
            }
        }
    }
}

