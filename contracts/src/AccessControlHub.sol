// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccessControlHub
 * @notice Centralized role management for EventVerse ecosystem
 * @dev Single source of truth for permissions across all contracts
 */
contract AccessControlHub is AccessControl {
    
    // Role definitions
    bytes32 public constant PLATFORM_ADMIN = keccak256("PLATFORM_ADMIN");
    bytes32 public constant EVENT_ADMIN = keccak256("EVENT_ADMIN");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER");
    bytes32 public constant BADGE_ISSUER = keccak256("BADGE_ISSUER");
    bytes32 public constant REFUND_ADMIN = keccak256("REFUND_ADMIN");
    bytes32 public constant PAYMENT_ADMIN = keccak256("PAYMENT_ADMIN");
    
    // Role => address => granted
    mapping(bytes32 => mapping(address => bool)) private roleGrants;
    
    // address => all roles
    mapping(address => bytes32[]) private userRoles;
    
    // Role => address count
    mapping(bytes32 => uint256) public roleCount;
    
    event RoleGrantedHub(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevokedHub(bytes32 indexed role, address indexed account, address indexed sender);
    event EmergencyRoleRevocation(bytes32 indexed role, address indexed account);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PLATFORM_ADMIN, msg.sender);
        
        // Grant initial roles
        _setupRole(PLATFORM_ADMIN, msg.sender);
        _setupRole(EVENT_ADMIN, msg.sender);
        _setupRole(VERIFIER_ROLE, msg.sender);
        _setupRole(BADGE_ISSUER, msg.sender);
        _setupRole(REFUND_ADMIN, msg.sender);
        _setupRole(PAYMENT_ADMIN, msg.sender);
    }
    
    /**
     * @notice Grant role with tracking
     */
    function grantRoleWithTracking(bytes32 role, address account) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        if (!roleGrants[role][account]) {
            _grantRole(role, account);
            roleGrants[role][account] = true;
            userRoles[account].push(role);
            roleCount[role]++;
            
            emit RoleGrantedHub(role, account, msg.sender);
        }
    }
    
    /**
     * @notice Revoke role with tracking
     */
    function revokeRoleWithTracking(bytes32 role, address account) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        if (roleGrants[role][account]) {
            _revokeRole(role, account);
            roleGrants[role][account] = false;
            _removeRoleFromUser(account, role);
            roleCount[role]--;
            
            emit RoleRevokedHub(role, account, msg.sender);
        }
    }
    
    /**
     * @notice Emergency role revocation (no checks)
     */
    function emergencyRevokeRole(bytes32 role, address account) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        _revokeRole(role, account);
        roleGrants[role][account] = false;
        
        emit EmergencyRoleRevocation(role, account);
    }
    
    /**
     * @notice Batch grant roles
     */
    function batchGrantRoles(
        bytes32[] calldata roles,
        address[] calldata accounts
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(roles.length == accounts.length, "Length mismatch");
        
        for (uint256 i = 0; i < roles.length; i++) {
            if (!roleGrants[roles[i]][accounts[i]]) {
                _grantRole(roles[i], accounts[i]);
                roleGrants[roles[i]][accounts[i]] = true;
                userRoles[accounts[i]].push(roles[i]);
                roleCount[roles[i]]++;
                
                emit RoleGrantedHub(roles[i], accounts[i], msg.sender);
            }
        }
    }
    
    /**
     * @notice Batch revoke roles
     */
    function batchRevokeRoles(
        bytes32[] calldata roles,
        address[] calldata accounts
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(roles.length == accounts.length, "Length mismatch");
        
        for (uint256 i = 0; i < roles.length; i++) {
            if (roleGrants[roles[i]][accounts[i]]) {
                _revokeRole(roles[i], accounts[i]);
                roleGrants[roles[i]][accounts[i]] = false;
                _removeRoleFromUser(accounts[i], roles[i]);
                roleCount[roles[i]]--;
                
                emit RoleRevokedHub(roles[i], accounts[i], msg.sender);
            }
        }
    }
    
    /**
     * @notice Get all roles for an address
     */
    function getUserRoles(address account) external view returns (bytes32[] memory) {
        return userRoles[account];
    }
    
    /**
     * @notice Check if address has any of the roles
     */
    function hasAnyRole(address account, bytes32[] calldata roles) 
        external 
        view 
        returns (bool) 
    {
        for (uint256 i = 0; i < roles.length; i++) {
            if (hasRole(roles[i], account)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Check if address has all roles
     */
    function hasAllRoles(address account, bytes32[] calldata roles) 
        external 
        view 
        returns (bool) 
    {
        for (uint256 i = 0; i < roles.length; i++) {
            if (!hasRole(roles[i], account)) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * @notice Get role count
     */
    function getRoleCount(bytes32 role) external view returns (uint256) {
        return roleCount[role];
    }
    
    /**
     * @dev Internal: Remove role from user array
     */
    function _removeRoleFromUser(address account, bytes32 role) private {
        bytes32[] storage roles = userRoles[account];
        for (uint256 i = 0; i < roles.length; i++) {
            if (roles[i] == role) {
                roles[i] = roles[roles.length - 1];
                roles.pop();
                break;
            }
        }
    }
    
    /**
     * @dev Internal: Setup role
     */
    function _setupRole(bytes32 role, address account) private {
        _grantRole(role, account);
        roleGrants[role][account] = true;
        userRoles[account].push(role);
        roleCount[role]++;
    }
}