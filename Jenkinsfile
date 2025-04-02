pipeline {
    agent { node { label 'agent1' } }

    environment {
        CHROME_BIN = "/usr/bin/chromium-browser" // Needed for headless tests
        NODE_VERSION = '18' // Use your Node.js version
        APP_URL = "http://40.172.189.21:4200"
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
                sh '''
                    id
                    # Explicitly set NVM directory to ubuntu user's installation
                    export NVM_DIR="/home/ubuntu/.nvm"
                    
                    # Source NVM 
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
                    
                    
                    # Install specific Node version (define this at pipeline top)
                    nvm install $NODE_VERSION
                    nvm use $NODE_VERSION
                    
                    # Verify installation
                    node --version 
                    npm --version 
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    # Load NVM (same as in Install Node.js stage)
                    export NVM_DIR="/home/ubuntu/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

                    # Install dependencies
                    npm ci
                '''            
            }
        }

        stage('Lint Code') {
            steps {
                
                sh '''
                    # Load NVM (same as in Install Node.js stage)
                    export NVM_DIR="/home/ubuntu/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
                    
                    # Verify Node.js is available
                    node --version
                    npm --version
                    
                    npx run lint
                ''' 
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                    export NVM_DIR="/home/ubuntu/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

                    node --version
                    npm --version

                    # Ensure Chromium is correctly set
                    export CHROME_BIN=$(which chromium-browser)
                    
                    # Run tests with ChromeHeadless
                    npx ng test --no-watch --browsers=ChromeHeadless --code-coverage || return 0
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t my-angular-app .'
                }
            }
        }

        stage('Run Container Locally') {
            steps {
                script {
                    sh 'docker run -d -p 4200:80 --name angular-container my-angular-app'
                }
            }
        }

         // ✅ NEW: Integration / End-to-End Testing using Cypress
        stage('Run E2E Tests (Cypress)') {
            steps {
                sh '''
                    export NVM_DIR="/home/ubuntu/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
                    
                    # npm install cypress --save-dev (I installed it on the node machine)
                    # sudo apt-get install libgtk2.0-0t64 libgtk-3-0t64 libgbm-dev libnotify-dev libnss3 libxss1 libasound2t64 libxtst6 xauth xvfb
                    
                    npx cypress run --config baseUrl=http://localhost:4200
                    
                    # npx cypress run --browser chrome
                '''
            }
        }

        // ✅ NEW: Performance Testing using Lighthouse
        stage('Performance Testing (Lighthouse)') {
            steps {
                sh '''
                    docker run --rm --network=host femtopixel/google-lighthouse $APP_URL --chrome-flags="--headless" --output json > lighthouse-report.json
                '''
            }
        }

        // ✅ NEW: Security Testing using OWASP ZAP
        stage('Security Testing') {
            steps {
                sh '''
                    docker run --rm -v $(pwd):/zap/wrk -t owasp/zap2docker-stable zap-baseline.py -t $APP_URL -J zap-report.json
                    # docker run -v $(pwd):/zap/wrk -t owasp/zap2docker-stable zap-baseline.py -t http://localhost:4200 -J zap-report.json
                '''
            }
        }

        stage('Push Image to Registry') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            docker tag my-angular-app ataha99/my-angular-app:latest
                            docker push ataha99/my-angular-app:latest
                        '''
                    }
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
