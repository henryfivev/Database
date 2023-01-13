/*
 Navicat Premium Data Transfer

 Source Server         : MySQL
 Source Server Type    : MySQL
 Source Server Version : 80030
 Source Host           : localhost:3306
 Source Schema         : exp

 Target Server Type    : MySQL
 Target Server Version : 80030
 File Encoding         : 65001

 Date: 27/12/2022 14:02:56
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for customer
-- ----------------------------
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer`  (
  `custkey` int NOT NULL AUTO_INCREMENT,
  `name` char(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` char(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`custkey`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for item
-- ----------------------------
DROP TABLE IF EXISTS `item`;
CREATE TABLE `item`  (
  `itemkey` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `stock` int NULL DEFAULT 0,
  `retailprice` double NULL DEFAULT NULL,
  `cost` double NULL DEFAULT NULL,
  PRIMARY KEY (`itemkey`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `orderkey` int NOT NULL AUTO_INCREMENT,
  `custkey` int NULL DEFAULT NULL,
  `itemkey` int NULL DEFAULT NULL,
  `quantity` int NULL DEFAULT NULL,
  `totalprice` double NULL DEFAULT NULL,
  `profit` double NULL DEFAULT NULL,
  PRIMARY KEY (`orderkey`) USING BTREE,
  INDEX `custkey`(`custkey` ASC) USING BTREE,
  INDEX `itemkey`(`itemkey` ASC) USING BTREE,
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`custkey`) REFERENCES `customer` (`custkey`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`itemkey`) REFERENCES `item` (`itemkey`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for supplier
-- ----------------------------
DROP TABLE IF EXISTS `supplier`;
CREATE TABLE `supplier`  (
  `suppkey` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` char(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`suppkey`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for supply
-- ----------------------------
DROP TABLE IF EXISTS `supply`;
CREATE TABLE `supply`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `suppkey` int NULL DEFAULT NULL,
  `itemkey` int NULL DEFAULT NULL,
  `quantity` int NULL DEFAULT NULL,
  `totalcost` double NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `suppkey`(`suppkey` ASC) USING BTREE,
  INDEX `itemkey`(`itemkey` ASC) USING BTREE,
  CONSTRAINT `supply_ibfk_1` FOREIGN KEY (`suppkey`) REFERENCES `supplier` (`suppkey`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `supply_ibfk_2` FOREIGN KEY (`itemkey`) REFERENCES `item` (`itemkey`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `username` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `permission` int NULL DEFAULT NULL,
  PRIMARY KEY (`username`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
DROP TRIGGER IF EXISTS `TRI_Order_Insert`;
delimiter ;;
CREATE TRIGGER `TRI_Order_Insert` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
	DECLARE L_valuediff, L_availqty INT;
	set L_valuediff = NEW.quantity;
	
	SELECT stock INTO L_availqty
	FROM item
	WHERE itemkey = NEW.itemkey;
	
	IF(L_availqty - L_valuediff >=0) THEN
	BEGIN
		SELECT 'Quantity is enough' INTO @user_prompt;
		UPDATE item
		SET stock = stock - L_valuediff
		WHERE itemkey = NEW.itemkey;
	END;
	ELSE
		SIGNAL SQLSTATE '45000'
		SET message_text = 'Quantity is not enough';
	END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
DROP TRIGGER IF EXISTS `TRI_Orders_pricing`;
delimiter ;;
CREATE TRIGGER `TRI_Orders_pricing` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
	DECLARE L_price, L_cost REAL;
	
	SELECT retailprice INTO L_price
	FROM item
	WHERE itemkey = NEW.itemkey;
	
	SELECT cost INTO L_cost
	FROM item
	WHERE itemkey = NEW.itemkey;
	
	SET NEW.totalprice = L_price * NEW.quantity;
	SET NEW.profit = (L_price - L_cost) * NEW.quantity;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table supply
-- ----------------------------
DROP TRIGGER IF EXISTS `TRI_Supply_Cost`;
delimiter ;;
CREATE TRIGGER `TRI_Supply_Cost` BEFORE INSERT ON `supply` FOR EACH ROW BEGIN
	DECLARE L_cost REAL;
	
	SELECT cost INTO L_cost
	FROM item
	WHERE itemkey = NEW.itemkey;
	
	SET NEW.totalcost = L_cost * NEW.quantity;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table supply
-- ----------------------------
DROP TRIGGER IF EXISTS `TRI_Supply_Insert`;
delimiter ;;
CREATE TRIGGER `TRI_Supply_Insert` AFTER INSERT ON `supply` FOR EACH ROW BEGIN
	DECLARE L_valuediff INT;
	SET L_valuediff = NEW.quantity;
	UPDATE item SET stock = stock + L_valuediff
	WHERE itemkey = NEW.itemkey;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
