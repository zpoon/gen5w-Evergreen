package com.hkmc.hev;

/** Test stand-in for the car's IHEVService: only its Stub's transaction number field. */
public interface IHEVService {
    abstract class Stub {
        static final int TRANSACTION_getHEVStatus = 3;
    }
}
