﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Liberty.Infrastructure.Domain
{
    public interface IRepository<T, TId> : IReadOnlyRepository<T, TId>
    {
        void Create(T entity);
        void Modify(T entity);
        void Delete(T entity);
    }
}
