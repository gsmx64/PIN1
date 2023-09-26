pipeline {
  agent any

  options {
    timeout(time: 2, unit: 'MINUTES')
  }

  environment {
    ARTIFACT_ID = "elbuo8/webapp:${env.BUILD_NUMBER}"
  }
  
  stages {
    stage('Building image') {
      steps {
        sh '''
        docker build -t testapp .
        '''  
      }
    }
    stage('Run tests') {
      steps {
        sh "docker run testapp npm test"
      }
    }
    stage('Mocha Tests') {
      steps {
        sh '''
        npm install mocha-junit-reporter --save-dev
        npm install MOCHA_FILE=./jenkins-test-results.xml ./node_modules/.bin/mocha tests/** --reporter mocha-junit-reporter
        '''
      }
    }
    stage('Deploy Image') {
      steps {
        sh '''
        docker tag testapp 127.0.0.1:5000/mguazzardo/testapp
        docker push 127.0.0.1:5000/mguazzardo/testapp   
        '''
      }
    }
  }
}


    
  

