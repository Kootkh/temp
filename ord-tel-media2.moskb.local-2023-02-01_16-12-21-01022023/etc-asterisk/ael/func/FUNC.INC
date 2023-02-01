//
 Set(LOCAL(fnc)=${CUT(fn,\(,1)});
 Set(LOCAL(arg)=${CUT(fn,\(,2)});
 Set(LOCAL(arg)=${CUT(arg,\),1)});

// NoOp(maxx: fnc ${fnc});

 switch ("${fnc}") {
  case "Func":
//   NoOp(HASH(res)=ODBC_FUNC(${arg},${cid},${BIND}));
    Set(HASH(res)=${ODBC_FUNC(${arg},${cid},${BIND})}); // Is function defined?
//    NoOp(maxx: scalar ${res} for hash keys for ${fnc} with Macro ${HASH(res,Macro)}: ${HASHKEYS(res)});
    if ("${HASH(res,Macro)}"!="") {
    &${HASH(res,Macro)}(${HASH(res,P1)},${HASH(res,P2)},${HASH(res,P3)},${HASH(res,P4)},${HASH(res,P5)},${HASH(res,P6)},${HASH(res,P7)},${HASH(res,P8)},${HASH(res,P9)},${HASH(res,P10)},${HASH(res,P11)},${HASH(res,P12)});
//    NoOp(RESULT=${RESULT});
   }
   break;

  case "Exten":
   Set(HASH(res)=${ODBC_EXTEN(${arg},${BIND})});
   if ("${HASH(res,Exten)}"!="") {
    Set(LOCAL(args)=${REPLACE(arg,\|,\,)});
    Set(__dnid=${CUT(args,\,,1)});
    if ("${CUT(args,\,,2)}"!="") Set(__BIND=${CUT(args,\,,2)});
    //NoOp(maxx: func hash keys for exten: ${HASHKEYS(res)});
    &exten(fake);
   }
   break;

  default:
   Set(LOCAL(args)=${REPLACE(arg,\|,\,)});
   &${fnc}(${args});
 }

 NoOp(RESULT=${RESULT});

