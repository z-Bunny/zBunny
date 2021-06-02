//SPDX-License-Identifier: Unlicensed

/**
  * zBunny requirements:
  *     1. 10% fee for each transaction
  *         1). 4% for farming pool
  *         2). 4% fee is distributed to each holding address which is include in BNB+CAKE reward pool
  *         3). 1% is used to add liquidity
  *         4). 1% for destruction
  *     2. The reward storage method is BNB, which will be exchanged for 80% Cake + 20% BNB when claim
  *     3. Anti-whale
  *         Transactions (sell/buy and wallet transfer) that trade more than 0.1%(default) of the total supply will be rejected.
  *         This will protect price movement as well. The transaction though can be carried out through our dAPP feature of disruptive transfers.
  *         Whales who make a transfer (between 2 wallets) that is larger than 0.1% of the total supply will be charged for 1 BNB.
  *         These 1 BNB go straight to the pool in the Earn BNB+CAKE feature.
  *     4. Collection cycle
  *         The default is 6 hours. When the address balance increases, it will be extended by 6 hours from the current time.
  */

pragma solidity >=0.6.8;
pragma experimental ABIEncoderV2;

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by revert+ing the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an BNB balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
}


library Utils {
    using SafeMath for uint256;

    function swapTokensForEth(
        address routerAddress,
        address bunnyAddress,
        uint256 tokenAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = bunnyAddress;
        path[2] = pancakeRouter.WETH();

        // make the swap swapExactTokensForETH
        pancakeRouter.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 360
        );
    }

    // exchange tokens from BNB
    function swapETHForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount,
        address tokenAddress
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = tokenAddress;

        // make the swap
        pancakeRouter.swapExactETHForTokens{value: ethAmount}(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    // exchange tokens from other tokens
    function swapExactTokensForTokens(
        address routerAddress,
        uint amountIn,
        uint amountOutMin,
        address tokenOutAddress,
        address to
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenOutAddress;

        pancakeRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            block.timestamp + 360);
    }

    // add liquidity
    function addLiquidity(
        address routerAddress,
        address tokenAddress,
        uint amountADesired,
        uint amountBDesired,
        address to
    ) public{
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);
        pancakeRouter.addLiquidity(
            address(this),
            tokenAddress,
            amountADesired,
            amountBDesired,
            0,
            0,
            to,
            block.timestamp + 360);
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller i not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unLock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}


contract zBunny is Context, IBEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    // 210 billion
    uint256 private _totalSupply = 21e28;
    string private _name = "zBunny";
    string private _symbol = "zBunny";
    uint8 private _decimals = 18;
    uint256 private constant BALANCE_ZERO = 0;
    uint256 private constant DOUBLE = 2;

    // bunny foundation address
    address payable public foundationAddress = 0x894946d395d8147Fefcc3BD0cC8A42c9ef807eC4;

    // pancakeSwap router address
    address payable public constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // BUNNY token address
    address public constant BUNNYAddress = 0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51;

    // WBNB token address
    address public constant BNBAddress   = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // USDT token address
    address public constant USDTAddress  = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // CAKE token address
    address public constant CAKEAddress = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    // burn address
    address public constant burnAddress = address(0x000000000000000000000000000000000000dEaD);

    // farm pool contract address
    address public farmAddress;


    // every account information
    struct account{
        address addr;
        uint256 balance;
        uint256 rewardBNB;
        uint256 nextAvailableClaimDate;
    }
    mapping(address => account) public _accounts;
    address[] addresses;

    mapping(address => mapping(address => uint256)) private _allowances;

    // If your address is in the mapping, and the value of ture will waive the 10% fee
    mapping(address => bool) private _isExcludedFromFee;

    // If your address is in the mapping, and the value of ture，you will be allowed to make large transfers at no extra charge
    mapping(address => bool) private _isExcludedFromMaxTx;

    // If you transfer all your balance out, there will be no reward for holding coins at that address for 50 years
    // If you want to continue to claim your prize, just change your address
    mapping(address => bool) private _isExcluded;
    address[] excluded;

    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;

    // Innovation for protocol by zBunny Team
    uint256 public rewardCycleBlock = 6 hours;
    
    // 50 years locked
    uint256 public constant FIFTY_YEARS = 50 * 365 days;

    // should be 0.1% per transaction, will be set at activateContract() function
    uint256 public _maxTxAmount = _totalSupply;

    // if transfer amount larger than 0.1%, take 1 bnb to reward
    uint256 public disruptiveCoverageFee = 1 ether;

    //transfer fee 10%
    uint256 public _taxFee = 10;
    //4$ reward to lp pool
    uint256 public _taxFee2Farm = 4;
    //burned  1%
    uint256 public _taxFee2Burn = 1;
    // if in exclude list remove fee, and set after action
    uint256 private _previousTaxFee = _taxFee;

    //if reward lager than 1 bnb, take 20% to foundation
    uint256 public rewardThreshold = 1 ether;

    // 0.001% max tx amount will trigger swap and add liquidity
    uint256 public minTokenNumberToSell = _totalSupply.mul(1).div(10000).div(10);

    event SwapAndLiquifyEnabledUpdated(bool enabled);

    event ClaimBNBAndCAKESuccessfully(
        address recipient,
        uint256 ethReceived,
        uint256 nextAvailableClaimDate
    );

    constructor () public {
        // parameters: address , balance , lastRewardBlockNum , rewardBNB , nextAvailableClaimDate
        _accounts[_msgSender()] = account(_msgSender(), _totalSupply, BALANCE_ZERO, block.timestamp.add(rewardCycleBlock));

        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(routerAddress);
        // set the rest of the contract variables
        pancakeRouter = _pancakeRouter;

        // Create a pancake pair for this new token
        address pancakePair_ = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), BUNNYAddress);
        pancakePair = pancakePair_;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // exclude from max tx
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[burnAddress] = true;
        _isExcludedFromMaxTx[address(0)] = true;

        // exclude from reward
        _excludeFromReward(pancakePair_);
        _excludeFromReward(burnAddress);
        _excludeFromReward(address(this));
       
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account_) public view override returns (uint256) {
        return _accounts[account_].balance;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount, 0);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount, 0);
         _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    // set farm contract address
    function setFarmAddress(address farmAddress_) public onlyOwner {
        farmAddress = farmAddress_;
    }

    // Set the address to be locked for 50 years and cannot receive income
    function excludeFromReward(address account_) external onlyOwner{
        _excludeFromReward(account_);
    }

    // total liquidity pool
    function totalLiquidityPool() external view returns(uint256 swapTotalValue){
        swapTotalValue = lpInUSDT();
    }

    function lpInUSDT() internal view returns(uint256 lpValue){
        address[] memory path = new address[](3);
        path[0] = BUNNYAddress;
        path[1] = BNBAddress;
        path[2] = USDTAddress;

        //calc 1 bunny value
        uint[] memory amounts = pancakeRouter.getAmountsOut(1, path);
        //total bunny value
        lpValue = amounts[path.length - 1].mul(LPPoolValue());
    }

    //get lp's bunny amount by pair address
    function LPPoolValue() private view returns(uint256 value){
        value = IBEP20(BUNNYAddress).balanceOf(pancakePair).mul(DOUBLE);
    }
    
    function _excludeFromReward(address account_) internal {
        require(!_isExcluded[account_], "Account is already excluded from reward");
        _isExcluded[account_] = true;
        excluded.push(account_);
        _accounts[account_].nextAvailableClaimDate = block.timestamp.add(FIFTY_YEARS);
    }

    // Add back rewards
    function includeInReward(address account_) external onlyOwner {
        require(_isExcluded[account_], "Account is already included in reward");
        _isExcluded[account_] = false;
        for(uint i = 0; i < excluded.length; i++) {
            if(excluded[i] == account_){
                excluded[i] = excluded[excluded.length - 1];
                excluded.pop();
                break;
            }
        }
    }

    function isExcludedFromReward(address account_) external view returns (bool) {
        return _isExcluded[account_];
    }

    // exclude from fee, if you are on this whitelist, you will be exempted from 10% fee.
    function excludeFromFee(address account_) external onlyOwner {
        require(!_isExcludedFromFee[account_], "Account is already excluded from fee");
        _isExcludedFromFee[account_] = true;
    }

    // include from fee， your transfer will be charged 10% fee
    function includeInFee(address account_) external onlyOwner {
        require(_isExcludedFromFee[account_], "Account is already included in fee");
        _isExcludedFromFee[account_] = false;
    }

    function isExcludedFromFee(address account_) external view returns (bool) {
        return _isExcludedFromFee[account_];
    }

    // exclude from max tx, if you are on this whitelist, you will be able to make large transfers.
    function excludeFromMaxTx(address address_, bool value) external onlyOwner {
        _isExcludedFromMaxTx[address_] = value;
    }

    // include from max tx， you will not be able to make large transfers, if you make a large transfer, 1BNB will be charged.
    function updateTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    // remove 10% fee
    function removeAllFee() private {
        if (_taxFee == 0) return;
        _previousTaxFee = _taxFee;
        _taxFee = 0;
    }

    // restore 10% fee
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
    }

    // query how much BNB + CAKE rewards you will get.
    function queryReward() external view returns(uint256 BNBReward, uint256 CAKEReward){
        if(_accounts[_msgSender()].rewardBNB == 0) return (0,0);
        BNBReward = _accounts[_msgSender()].rewardBNB.div(5);
        CAKEReward = _accounts[_msgSender()].rewardBNB.sub(BNBReward);
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = CAKEAddress;
        uint[] memory result = pancakeRouter.getAmountsOut(CAKEReward,path);
        CAKEReward = result[1];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // If your account does not exist, a new account will be created.
    function addNewAccount(address account_) private {
        if(_accounts[account_].addr == address(0)){
            _accounts[account_] = account(account_, BALANCE_ZERO, BALANCE_ZERO, block.timestamp.add(rewardCycleBlock));
            addresses.push(account_);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount,
        uint256 value
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(from != to, "BEP20: from and to address equals");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount < _totalSupply, "Transfer amount must be less than total supply");

        // If your account does not exist, a new account will be created.
        addNewAccount(to);

        // Determine whether it is a large transfer
        ensureMaxTxAmount(from, to, amount, value);

        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool isTakeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            isTakeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, isTakeFee);
    }

    // Determine whether it is a large transfer
    function ensureMaxTxAmount(
        address from,
        address to,
        uint256 amount,
        uint256 value
    ) private view{
        //  default will be false         default will be false
        if (!_isExcludedFromMaxTx[from] && !_isExcludedFromMaxTx[to]) {
            if (value < disruptiveCoverageFee) {
                // if not larger than max tx amount, it is a normal transfer action
                require(amount < _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }
        }
    }

    // swap and liquify
    function swapAndLiquify(address from, address to) private{
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancake pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        contractTokenBalance = contractTokenBalance >= _maxTxAmount ? _maxTxAmount : contractTokenBalance;

        bool shouldSell = contractTokenBalance >= minTokenNumberToSell;

        if (
            shouldSell &&
            from != pancakePair &&
            !(from == address(this) && to == address(pancakePair)) // swap 1 time
        ) {
            // to farming
            uint256 farmingFeeBalance = 0;
            if(farmAddress != address(0)){
                farmingFeeBalance = contractTokenBalance.mul(_taxFee2Farm).div(100);
                toFarm(farmingFeeBalance);
            }

            // to reward & swap
            uint256 rewardAndSwapFeeBalance= contractTokenBalance.sub(farmingFeeBalance);
            toRewardAndSwap(rewardAndSwapFeeBalance);
        }
    }

    // 4% fee will be transfer to farming pool.
    function toFarm(uint256 amount_) private {
        require(farmAddress != address(0), "Error: farmAddress cann`t equals address zero");
        Utils.swapExactTokensForTokens(
            routerAddress,
            amount_,
            0, // accept any amount of tokens
            BUNNYAddress,
            farmAddress
        );
    }


    // 4%(reward) + 1%(add liquidity) = 5%
    function toRewardAndSwap(uint256 amount_) private {
        // 4% BUNNY to reward
        // 0.5% BUNNY and 0.5% zBunny to swap
        // 4.5% * 2 = 9%
        uint256 swapRate = 9;
        uint256 tokenForSwapAmount = amount_.mul(swapRate).div(10);
        uint256 tokenForLiquidityAmount = amount_.sub(tokenForSwapAmount);

        uint256 beforeSwapBNB = address(this).balance;
        // swap Token to BNB
        Utils.swapTokensForEth(
            routerAddress,
            BUNNYAddress,
            tokenForSwapAmount
        );

        uint256 afterSwapBNB = address(this).balance;
        uint256 swapBNB = afterSwapBNB.sub(beforeSwapBNB); // 9/10

        // add zBunny-Bunny liquidity
        uint256 liquidityBNB = swapBNB.div(9);   // 1/10
        addLiquify(tokenForLiquidityAmount, liquidityBNB);

        // return the last bnb by swap
        uint256 rewardBNB = swapBNB.sub(liquidityBNB);  // 8/10  4%

        //refresh accounts' rewards
        updateAccountRewards(rewardBNB);
    }

    // add liquidity
    function addLiquify(uint256 tokenAmount_, uint256 liquidityBNB_) private{
        // swap BNB to BUNNY
        Utils.swapETHForTokens(
            routerAddress,
            address(this),
            liquidityBNB_,
            BUNNYAddress
        );
        
        // add liquidity
        uint256 liquidityBUNNY = IBEP20(BUNNYAddress).balanceOf(address(this));
        Utils.addLiquidity(
            routerAddress,
            BUNNYAddress,
            tokenAmount_,
            liquidityBUNNY,
            owner()
        );
    }

    function updateAccountRewards(uint256 rewardBNB) private{
        if(rewardBNB == 0)  return;

        // Exclude address balances that do not distribute rewards within 50 years.
        uint256 totalEffective = calculateEffectiveTotalSupply();

        // distribute reward
        for(uint256 i = 0; i < addresses.length; i++) {
            if(_isExcluded[addresses[i]]){
                continue;
            }
            uint256 rewardBNB2Person = _accounts[addresses[i]].balance.mul(rewardBNB).div(totalEffective);
            _accounts[addresses[i]].rewardBNB = _accounts[addresses[i]].rewardBNB.add(rewardBNB2Person);
        }
    }

    // Exclude address balances that do not distribute rewards within 50 years.
    function calculateEffectiveTotalSupply() private view returns(uint256 totalEffective){
        totalEffective = _totalSupply;
        for(uint i = 0; i < excluded.length; i++) {
            totalEffective = totalEffective.sub(_accounts[excluded[i]].balance);
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool isTakeFee) private {
        if (!isTakeFee)  removeAllFee();

        // If you transfer all your balance out, there will be no reward for holding coins at that address for 50 years
        if(amount == balanceOf(sender)){

            _accounts[sender].nextAvailableClaimDate = block.timestamp.add(FIFTY_YEARS);

            //remove reward from this address, and distribute to other holders
            updateAccountRewards(_accounts[sender].rewardBNB);
            _accounts[sender].rewardBNB = 0;
        }

        // top up claim cycle
        refreshClaimCycleAfterTransfer(recipient);

        // 10% * amount = fee
        uint256 fee = distributeFee(amount);

        uint256 receiveAmount = amount.sub(fee);
        _accounts[sender].balance = _accounts[sender].balance.sub(amount);
        _accounts[recipient].balance = _accounts[recipient].balance.add(receiveAmount);

        if (!isTakeFee) restoreAllFee();

        emit Transfer(sender,recipient,receiveAmount);
    }

    // 10% fee for distribution。
    function distributeFee(uint256 amount) private returns(uint256 fee){
        // 10% fee, and distribute
        fee = amount.mul(_taxFee).div(100);
        // if exclude from fee ,remove all fee
        if(fee == 0) return 0;

        _accounts[address(this)].balance = _accounts[address(this)].balance.add(fee);
        emit Transfer(_msgSender(), address(this), fee);

        // 1% burn   9% remain and swap later
        uint256 fee2Burn = amount.mul(_taxFee2Burn).div(100);
        _accounts[address(this)].balance = _accounts[address(this)].balance.sub(fee2Burn);
        _accounts[burnAddress].balance = _accounts[burnAddress].balance.add(fee2Burn);
        emit Transfer(address(this), burnAddress, fee2Burn);
    }

    //reset claim cycle(default 6 hours)
    function refreshClaimCycleAfterTransfer(address recipient) private {
        _accounts[recipient].nextAvailableClaimDate = block.timestamp.add(rewardCycleBlock);
    }

    // Define large transfers, if transfer amount larger than 0.1%(default), take 1 bnb to reward
    function setMaxTxRate(uint256 maxTxRate) public onlyOwner {
        _maxTxAmount = _totalSupply.mul(maxTxRate).div(10000);
    }

    // claim reward : 80% CAKE + 20% BNB
    function claimReward() isHuman nonReentrant public {
        require(_accounts[_msgSender()].nextAvailableClaimDate <= block.timestamp, 'Error: next available not reached');
        require(_accounts[_msgSender()].rewardBNB <= address(this).balance, 'Error: out of reward');
        require(_accounts[_msgSender()].rewardBNB > 0, 'Error: none of reward');

        // reward threshold
        uint256 reward = _accounts[_msgSender()].rewardBNB;
        if (reward >= rewardThreshold) {
            uint256 foundationAmount = reward.div(5);
            (bool success, ) = address(foundationAddress).call{ value: foundationAmount }("");
            require(success, "Address: unable to send value, charity may have reverted");
            reward = reward.sub(foundationAmount);
        }

        // reward: 80% CAKE  20% BNB
        uint256 BNBReward = reward.div(5);
        uint256 CAKERewardFromBNB = reward.sub(BNBReward);

        // update rewardCycleBlock
        refreshClaimCycleAfterTransfer(_msgSender());
        emit ClaimBNBAndCAKESuccessfully(_msgSender(), reward, _accounts[_msgSender()].nextAvailableClaimDate);

        // Swap CAKE to account
        swapCAKE(CAKERewardFromBNB);

        (bool sent,) = address(_msgSender()).call{value : BNBReward}("");
        require(sent, 'Error: Cannot withdraw reward');
    }

    // swap CAKE from BNB
    function swapCAKE(uint256 amount_) private{
        Utils.swapETHForTokens(
            routerAddress,
            _msgSender(),
            amount_,
            CAKEAddress
        );
    }

    // disruptive transfer
    // if transfer amount greater than max tx amount ,1 BNB will be take
    function disruptiveTransfer(address recipient, uint256 amount) public payable returns (bool) {
        require(amount > _maxTxAmount, "disruptive transfer must greater than maxTxAmount.");
        _transfer(_msgSender(), recipient, amount, msg.value);
        // if transfer amount greater than max tx amount ,1 BNB will distribute to every one who include in reward
        updateAccountRewards(msg.value);
        return true;
    }

    // activate contract, set initial values of necessary parameters
    function activateContract() public onlyOwner {
        // reward claim
        rewardCycleBlock = 6 hours;

        // protocol
        disruptiveCoverageFee = 1 ether;

        //calc max tx amount
        setMaxTxRate(10);

        // approve contract
        _approve(address(this), address(pancakeRouter), 2 ** 256 - 1);
        TransferHelper.safeApprove(pancakeRouter.WETH(), address(pancakeRouter), 2 ** 256 - 1);
        TransferHelper.safeApprove(BUNNYAddress, address(pancakeRouter), 2 ** 256 - 1);
    }

    // update reward cycle(default 6 hours)
    function updateRewardCycleBlock(uint256 newCycle_) public onlyOwner {
        rewardCycleBlock = newCycle_;
    }

    // update foundation address
    function updateFoundationAddress(address payable foundationAddress_) public onlyOwner {
        foundationAddress = foundationAddress_;
    }

    function migrateTokentoFoundation() public onlyOwner {
        removeAllFee();
        _transfer(address(this), foundationAddress, balanceOf(address(this)), 0);
        restoreAllFee();
    }

    function migrateBnbtoFoundation() public onlyOwner {
        (bool success, ) = address(foundationAddress).call{ value: address(this).balance }("");
        require(success, "Address: unable to send value, foundation may have reverted");
    }

}