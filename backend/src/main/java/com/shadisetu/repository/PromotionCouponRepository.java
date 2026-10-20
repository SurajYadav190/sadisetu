package com.shadisetu.repository;

import com.shadisetu.entity.PromotionCoupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface PromotionCouponRepository extends JpaRepository<PromotionCoupon, Long> {
    Optional<PromotionCoupon> findByCodeIgnoreCaseAndActiveTrue(String code);
    Optional<PromotionCoupon> findByCodeIgnoreCase(String code);
    boolean existsByCodeIgnoreCase(String code);
}
