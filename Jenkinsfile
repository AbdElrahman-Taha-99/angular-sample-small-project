pipeline {
    agent { node { label 'agent1' } }

    environment {
        CHROME_BIN = "/usr/bin/chromium-browser" // Needed for headless tests
        NODE_VERSION = '18' // Use your Node.js version
    }

    stages {
        stage('Checkout') {
            steps {
                // Clean workspace before checkout (optional but recommended)
                cleanWs()
                
                // Jenkins will handle the Git checkout
                git branch: 'main', 
                     url: 'git@github.com:AbdElrahman-Taha-99/angular-sample-small-project.git'
            }
        }

        stage('Install Node.js') {
            steps {
                //sh 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm install $NODE_VERSION && nvm use $NODE_VERSION'
                sh '''
                    # Explicitly set NVM directory to ubuntu user's installation
                    export NVM_DIR="/home/ubuntu/.nvm"
                    
                    # Source NVM if exists, otherwise fail clearly
                    if [ -s "$NVM_DIR/nvm.sh" ]; then
                        . "$NVM_DIR/nvm.sh"
                    else
                        echo "❌ ERROR: NVM not found at $NVM_DIR/nvm.sh"
                        exit 1
                    fi
                    
                    # Install specific Node version (define this at pipeline top)
                    nvm install $NODE_VERSION || { echo "❌ Node installation failed"; exit 1; }
                    nvm use $NODE_VERSION
                    
                    # Verify installation
                    node --version || { echo "❌ Node not available"; exit 1; }
                    npm --version || { echo "❌ NPM not available"; exit 1; }
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    # Load NVM (same as in Install Node.js stage)
                    export NVM_DIR="/home/ubuntu/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
                    
                    # Verify Node.js is available
                    node --version
                    npm --version
                    
                    # Install dependencies
                    npm ci
                '''            
            }
        }

        stage('Lint Code (Optional)') {
            steps {
                sh 'npm run lint'
            }
        }

        /*stage('Run Unit Tests') {
            steps {
                sh 'ng test --watch=false --browsers=ChromeHeadless'
            }
        }

        //stage('Build Angular App') {
        //    steps {
        //        sh 'ng build --configuration=production'
        //    }
        //}

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t my-angular-app .'
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }
                }
            }
        }

        stage('Push Image to Registry') {
            steps {
                script {
                    sh 'docker tag my-angular-app ataha99/my-angular-app:latest'
                    sh 'docker push ataha99/my-angular-app:latest'
                }
            }
        }

        //stage('Deploy to EC2') {
        //    steps {
        //        // Copy build to EC2 instance (update with your details)
        //        sh 'scp -i /path/to/your-ec2-key.pem -r dist/YOUR_PROJECT_NAME/* ec2-user@YOUR_EC2_IP:/var/www/html/'

        //        // Restart Nginx on EC2 to apply changes
        //        sh 'ssh -i /path/to/your-ec2-key.pem ec2-user@YOUR_EC2_IP "sudo systemctl restart nginx"'
        //    }
        //}*/
    }

    post {
        success {
            echo '✅ Build and deployment successful!'
        }
        failure {
            echo '❌ Build failed! Check Jenkins logs.'
        }
    }
}
