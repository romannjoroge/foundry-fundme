-include .env

build:; forge build
deploy-anchor:
	forge script script/DeployFundMe.s.sol --broadcast