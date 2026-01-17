#!/bin/bash

# Validation script to verify that our automation implements all steps from the guide

echo "Validating Isaac Sim automation script against the original guide..."

# Check that all required steps from the guide are implemented
SCRIPT_PATH="./isaac-sim-automation.sh"

# Step 1: Install gcc-11 and git-lfs
echo "1. Checking for gcc-11 and git-lfs installation..."
if grep -q "sudo apt install -y gcc-11 g++-11 git-lfs" "$SCRIPT_PATH"; then
    echo "   ✓ gcc-11 and git-lfs installation found"
else
    echo "   ✗ gcc-11 and git-lfs installation not found"
fi

# Check for alternatives setup
if grep -q "update-alternatives" "$SCRIPT_PATH"; then
    echo "   ✓ gcc/g++ alternatives setup found"
else
    echo "   ✗ gcc/g++ alternatives setup not found"
fi

# Check version verification
if grep -q "gcc --version" "$SCRIPT_PATH" && grep -q "g++ --version" "$SCRIPT_PATH"; then
    echo "   ✓ Version verification found"
else
    echo "   ✗ Version verification not found"
fi

# Step 2: Clone Isaac Sim repository
echo "2. Checking for Isaac Sim cloning..."
if grep -q "git clone --depth=1 --recursive --branch=develop" "$SCRIPT_PATH"; then
    echo "   ✓ Isaac Sim cloning with develop branch found"
else
    echo "   ✗ Isaac Sim cloning not found"
fi

# Check for git lfs commands
if grep -q "git lfs install" "$SCRIPT_PATH" && grep -q "git lfs pull" "$SCRIPT_PATH"; then
    echo "   ✓ Git LFS commands found"
else
    echo "   ✗ Git LFS commands not found"
fi

# Step 3: Build Isaac Sim
echo "3. Checking for Isaac Sim building..."
if grep -q "./build.sh" "$SCRIPT_PATH"; then
    echo "   ✓ Build command found"
else
    echo "   ✗ Build command not found"
fi

# Check for build verification
if grep -q "BUILD (RELEASE) SUCCEEDED" "$SCRIPT_PATH"; then
    echo "   ✓ Build verification found"
else
    echo "   ✗ Build verification not found"
fi

# Step 4: Environment setup
echo "4. Checking for environment setup..."
if grep -q "export ISAACSIM_PATH" "$SCRIPT_PATH" && grep -q "export ISAACSIM_PYTHON_EXE" "$SCRIPT_PATH"; then
    echo "   ✓ Environment variables found"
else
    echo "   ✗ Environment variables not found"
fi

# Step 5: Run Isaac Sim
echo "5. Checking for Isaac Sim execution..."
if grep -q "isaac-sim.sh" "$SCRIPT_PATH" && grep -q "LD_PRELOAD" "$SCRIPT_PATH"; then
    echo "   ✓ Isaac Sim execution found"
else
    echo "   ✗ Isaac Sim execution not found"
fi

# Step 6: Clone Isaac Lab
echo "6. Checking for Isaac Lab cloning..."
if grep -q "git clone --recursive https://github.com/isaac-sim/IsaacLab" "$SCRIPT_PATH"; then
    echo "   ✓ Isaac Lab cloning found"
else
    echo "   ✗ Isaac Lab cloning not found"
fi

# Step 7: Symbolic link setup
echo "7. Checking for symbolic link setup..."
if grep -q "ln -sfn" "$SCRIPT_PATH" && grep -q "_isaac_sim" "$SCRIPT_PATH"; then
    echo "   ✓ Symbolic link setup found"
else
    echo "   ✗ Symbolic link setup not found"
fi

# Step 8: Install Isaac Lab
echo "8. Checking for Isaac Lab installation..."
if grep -q "./isaaclab.sh --install" "$SCRIPT_PATH"; then
    echo "   ✓ Isaac Lab installation found"
else
    echo "   ✗ Isaac Lab installation not found"
fi

# Step 9: Run Isaac Lab training
echo "9. Checking for Isaac Lab training..."
if grep -q "./isaaclab.sh -p" "$SCRIPT_PATH" && grep -q "Isaac-Velocity-Rough-H1-v0" "$SCRIPT_PATH"; then
    echo "   ✓ Isaac Lab training found"
else
    echo "   ✗ Isaac Lab training not found"
fi

echo ""
echo "Validation complete!"